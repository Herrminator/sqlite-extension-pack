#define COMPILE_SQLITE_EXTENSIONS_AS_LOADABLE_MODULE 1

#if defined(_WIN64) || defined(_WIN32) || defined(__BORLANDC__)
  #define EXTENSION_EXPORT __declspec(dllexport)
#else
  #define EXTENSION_EXPORT
#endif

#ifdef COMPILE_SQLITE_EXTENSIONS_AS_LOADABLE_MODULE
#include "sqlite3ext.h"
SQLITE_EXTENSION_INIT1
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#endif

// #define IPV4_ONLY

#ifndef _WIN32
#  include <errno.h>
#  include <arpa/inet.h>
#else
#  include <winsock2.h>
#  include <ws2tcpip.h>
#  ifdef __BORLANDC__
#    include <systypes.h>
#    define in6_addr in_addr6
#    define IPV4_ONLY
#    define strcasecmp stricmp
     typedef uint32 uint32_t;
#  else
#    define strcasecmp _stricmp
#  endif
#endif

#define MIN(a, b) (((a) < (b)) ? (a) : (b))

static void readfileFunc(
  sqlite3_context *context,
  int argc,
  sqlite3_value **argv
){
  const char *zName;
  FILE *in;
  long nIn;
  void *pBuf;

  zName = (const char*)sqlite3_value_text(argv[0]);
  if( zName==0 ) return;
  in = fopen(zName, "rb");
  if( in==0 ) return;
  fseek(in, 0, SEEK_END);
  nIn = ftell(in);
  rewind(in);
  pBuf = sqlite3_malloc( nIn );
  if( pBuf && 1==fread(pBuf, nIn, 1, in) ){
    sqlite3_result_blob(context, pBuf, nIn, sqlite3_free);
  }else{
    sqlite3_free(pBuf);
  }
  fclose(in);
}

static void writefileFunc(
  sqlite3_context *context,
  int argc,
  sqlite3_value **argv
){
  FILE *out;
  const char *z;
  sqlite3_int64 rc;
  const char *zFile;

  zFile = (const char*)sqlite3_value_text(argv[0]);
  if( zFile==0 ) return;
  out = fopen(zFile, "wb");
  if( out==0 ) return;
  z = (const char*)sqlite3_value_blob(argv[1]);
  if( z==0 ){
    rc = 0;
  }else{
    rc = fwrite(z, 1, sqlite3_value_bytes(argv[1]), out);
  }
  fclose(out);
  sqlite3_result_int64(context, rc);
}

static void getenvFunc(
  sqlite3_context *context,
  int argc,
  sqlite3_value **argv
){
  const char *zName;
  char       *zOut = 0;
  char       errmsg[1024] = "Usage: getenv(name)";

  if (argc < 1)    { sqlite3_result_error(context, errmsg, -1); return; }

  zName = (const char*)sqlite3_value_text(argv[0]);
  if( zName==0 ) return;
  zOut = getenv(zName);
  if (zOut != 0)
    sqlite3_result_text(context, zOut, -1, SQLITE_TRANSIENT);
  else
    sqlite3_result_null(context); // TODO: really? ignore invalid ip_addresses
}


static void inet_aton_Func(sqlite3_context *context, int argc, sqlite3_value **argv)
{
  int             arg  = 0;
  int             ntoh = 1; // translate net to host
  const char      *zAf, *zIP;
  int             af;
  unsigned long   rc;
  char            ipBuf[65];
  char*           maskp;
  uint32_t        mask = 0xFFFFFFFF;

#if !defined(IPV4_ONLY)
  char            errmsg[1024] = "Usage: inet_aton(['AF_INET'|'AF_INET6',] ip [, ntoh=1])";
  struct in_addr  v4;
  struct in6_addr v6;
#else
  char            errmsg[1024] = "Usage: inet_aton(['AF_INET',] ip)";
#endif

  if (argc < 1)    { sqlite3_result_error(context, errmsg, -1); return; }
  else if (argc > 1 && !isdigit(((const char*) sqlite3_value_text(argv[0]))[0])) {
    zAf = (const char*) sqlite3_value_text(argv[arg++]);
    if( zAf == 0 ) { sqlite3_result_error(context, errmsg, -1); return; }
    zIP = (const char*) sqlite3_value_text(argv[arg++]);
  } else {
    zAf = "AF_INET";
    zIP = (const char*) sqlite3_value_text(argv[arg++]);
  }
  if (arg < argc)
    ntoh = sqlite3_value_int(argv[arg++]);

  if( arg < argc || zIP == 0 ) { sqlite3_result_error(context, errmsg, -1); return; };
  
  if      (!strcasecmp(zAf, "AF_INET"))  af = AF_INET;
#if !defined(IPV4_ONLY)
  else if (!strcasecmp(zAf, "AF_INET6")) af = AF_INET6;
#endif
  else { sqlite3_result_error(context, errmsg, -1); return; }

  strncpy(ipBuf, zIP, sizeof(ipBuf)-1);
  maskp = strchr(ipBuf, '/');
  if (maskp != 0) {
	  *maskp++ = '\0';
	  if (af == AF_INET) mask = 0xFFFFFFFF << (32 - MIN(atoi(maskp), 32));
	  // TODO: IPv6 mask (or at least a warning...)
  }

#ifndef IPV4_ONLY
  rc = inet_pton(af, ipBuf, af == AF_INET ? (void*) &v4 : (void*) &v6);

  if (rc == 1) {
    if (af == AF_INET) sqlite3_result_int64(context, ntoh ? ntohl(v4.s_addr) & mask : v4.s_addr & htonl(mask));
    else               sqlite3_result_blob( context, v6.s6_addr, sizeof(v6.s6_addr), SQLITE_TRANSIENT);
  } else if (rc == 0) {
    sqlite3_result_null(context); // TODO: really? ignore invalid ip_addresses
  } else {
#ifndef _WIN32
    strncpy(errmsg, strerror(errno), sizeof(errmsg));
#else
    wchar_t *s = NULL;
    FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS, 
                   NULL, WSAGetLastError(), MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPWSTR) &s, 0, NULL);
    sprintf(errmsg, "WinSock error: %S", s);
    LocalFree(s);
#endif
    sqlite3_result_error(context, errmsg, -1);
  }
#else // IPV4_ONLY
  rc = inet_addr(ipBuf);
  if (rc != INADDR_NONE) sqlite3_result_int64(context, ntoh ? ntohl(rc) & mask : rc & htonl(mask));
  else                   sqlite3_result_null(context);
#endif
}

EXTENSION_EXPORT int sqlite3_extension_init( // sqlite3_sqlitetjutil_init(
  sqlite3 *db, 
  char **pzErrMsg, 
  const sqlite3_api_routines *pApi
){
  int rc = SQLITE_OK;
  SQLITE_EXTENSION_INIT2(pApi);
  (void)pzErrMsg;  /* Unused parameter */
  rc =   sqlite3_create_function(db, "readfile",  1, SQLITE_UTF8, 0, readfileFunc, 0, 0);
  if( rc==SQLITE_OK ){
    rc = sqlite3_create_function(db, "writefile", 2, SQLITE_UTF8, 0, writefileFunc, 0, 0);
  }
  if( rc==SQLITE_OK ){
    rc = sqlite3_create_function(db, "inet_aton", -1, SQLITE_UTF8|SQLITE_INNOCUOUS, 0, inet_aton_Func, 0, 0);
  }
  if( rc==SQLITE_OK ){
    rc = sqlite3_create_function(db, "getenv", -1, SQLITE_UTF8|SQLITE_INNOCUOUS, 0, getenvFunc, 0, 0);
  }
  return rc;
}
