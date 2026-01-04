#include "sqlite3ext.h"
extern sqlite3_api_routines *sqlite3_api;

#include <ctype.h>
#include <stdint.h>
#include <assert.h>

// Original in sqlite3.c
#ifdef SQLITE_EXTENSIONS_SOUNDEX
typedef uint8_t         u8;
typedef uint16_t        u16;
typedef int64_t         i64;

// # define sqlite3Toupper(x)   toupper((unsigned char)(x))
// # define sqlite3Isalpha(x)   isalpha((unsigned char)(x))

#if 0 // worth a try, but slow! (factor 30)
#include <locale.h>
int skip_non_alpha(const u8* zIn) {
	int i;
	char* loc = setlocale(LC_CTYPE, NULL);
	setlocale(LC_CTYPE, "C"); // HACK ALERT: We should skip (or convert) utf-8 characters properly!
	for(i=0; zIn[i] && !sqlite3Isalpha(zIn[i]); i++){}
  	setlocale(LC_CTYPE, loc);
	return i;
}
#endif

#ifdef _WINDOWS
#include <locale.h>
static _locale_t _soundex_locale = 0;

inline int soundexIsalpha(unsigned char x) {
	if (_soundex_locale == 0) _soundex_locale = _create_locale(LC_CTYPE, "C");
	return _isalpha_l(x, _soundex_locale);
}

inline int soundexToupper(unsigned char x) {
	if (_soundex_locale == 0) _soundex_locale = _create_locale(LC_CTYPE, "C");
	return _toupper_l(x, _soundex_locale);
}

#else
// slower than isalpha(x) ! But we don't want locale involved...
#define soundexIsalpha(x)   (((x) >= 'A' && (x) <= 'Z') || ((x) >= 'a' && (x) <= 'z'))
#define soundexToupper(x)   toupper((unsigned char)(x))
#endif

# define sqlite3Toupper(x)   soundexToupper((unsigned char)(x))
# define sqlite3Isalpha(x)   soundexIsalpha((unsigned char)(x))

// Original in sqlite3.c
/*
** Compute the soundex encoding of a word.
**
** IMP: R-59782-00072 The soundex(X) function returns a string that is the
** soundex encoding of the string X. 
*/
void soundexFunc(
  sqlite3_context *context,
  int argc,
  sqlite3_value **argv
){
  char zResult[8];
  const u8 *zIn;
  int i, j;
  static const unsigned char iCode[] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 1, 2, 3, 0, 1, 2, 0, 0, 2, 2, 4, 5, 5, 0,
    1, 2, 6, 2, 3, 0, 1, 0, 2, 0, 2, 0, 0, 0, 0, 0,
    0, 0, 1, 2, 3, 0, 1, 2, 0, 0, 2, 2, 4, 5, 5, 0,
    1, 2, 6, 2, 3, 0, 1, 0, 2, 0, 2, 0, 0, 0, 0, 0,
  };
  assert( argc==1 );
  zIn = (u8*)sqlite3_value_text(argv[0]);
  if( zIn==0 ) zIn = (u8*)"";
  for(i=0; zIn[i] && !sqlite3Isalpha(zIn[i]); i++){}
  if( zIn[i] ){
    u8 prevcode = iCode[zIn[i]&0x7f];
    zResult[0] = sqlite3Toupper(zIn[i]);
    for(j=1; j<4 && zIn[i]; i++){
      int code = iCode[zIn[i]&0x7f];
      if( code>0 ){
        if( code!=prevcode ){
          prevcode = code;
          zResult[j++] = code + '0';
        }
      }else{
        prevcode = 0;
      }
    }
    while( j<4 ){
      zResult[j++] = '0';
    }
    zResult[j] = 0;
    sqlite3_result_text(context, zResult, 4, SQLITE_TRANSIENT);
  }else{
    /* IMP: R-64894-50321 The string "?000" is returned if the argument
    ** is NULL or contains no ASCII alphabetic characters. */
    sqlite3_result_text(context, "?000", 4, SQLITE_STATIC);
  }
}

#endif // SQLITE_EXTENSIONS_SOUNDEX

#ifdef SQLITE_EXTENSIONS_METAPHONE
// from https://github.com/geocommons/geocoder

#include <string.h>

/*
**  Character coding array
*/

static char vsvfn[26] = {
      1,16,4,16,9,2,4,16,9,2,0,2,2,2,1,4,0,2,4,4,1,0,0,0,8,0};
/*    A  B C  D E F G  H I J K L M N O P Q R S T U V W X Y Z      */

/*
**  Macros to access the character coding array
*/

#define vowel(x)  (vsvfn[(x) - 'A'] & 1)  /* AEIOU    */
#define same(x)   (vsvfn[(x) - 'A'] & 2)  /* FJLMNR   */
#define varson(x) (vsvfn[(x) - 'A'] & 4)  /* CGPST    */
#define frontv(x) (vsvfn[(x) - 'A'] & 8)  /* EIY      */
#define noghf(x)  (vsvfn[(x) - 'A'] & 16) /* BDH      */


static int metaphone(const char *Word, char *Metaph, int max_phones)
//  What a pity: our most expensive function (metaphone) seems to have a problem with the (Clang?-) optimizer ;( -O1 doesn't help, BTW...
#if defined (__clang__) // let's hope, it's just Clang
__attribute__((optnone))
#endif
{
      char *n, *n_start, *n_end;    /* Pointers to string               */
      char *metaph_start = Metaph, *metaph_end;    
                                    /* Pointers to metaph         */
      int ntrans_len = strlen(Word)+4;
      char *ntrans = (char *)sqlite3_malloc(sizeof(char) * ntrans_len);
                                    /* Word with uppercase letters      */
      int KSflag;                   /* State flag for X translation     */

      /*
      ** Copy word to internal buffer, dropping non-alphabetic characters
      ** and converting to upper case.
      */

      for (n = ntrans + 1, n_end = ntrans + ntrans_len - 2;
            *Word && n < n_end; ++Word)
      {
            if (isalpha(*Word))
                  *n++ = toupper(*Word);
      }

      if (n == ntrans + 1) {
            sqlite3_free(ntrans);
            Metaph[0]='\0';
            return 1;           /* Return if zero characters        */
      }
      else  n_end = n;          /* Set end of string pointer        */

      /*
      ** Pad with '\0's, front and rear
      */

      *n++ = '\0';
      *n   = '\0';
      n    = ntrans;
      *n++ = '\0';

      /*
      ** Check for PN, KN, GN, WR, WH, and X at start
      */

      switch (*n)
      {
      case 'P':
      case 'K':
      case 'G':
            if ('N' == *(n + 1))
                  *n++ = '\0';
            break;

      case 'A':
            if ('E' == *(n + 1))
                  *n++ = '\0';
            break;

      case 'W':
            if ('R' == *(n + 1))
                  *n++ = '\0';
            else if ('H' == *(n + 1))
            {
                  *(n + 1) = *n;
                  *n++ = '\0';
            }
            break;

      case 'X':
            *n = 'S';
            break;
      }

      /*
      ** Now loop through the string, stopping at the end of the string
      ** or when the computed Metaphone code is max_phones characters long.
      */

      KSflag = 0;              /* State flag for KStranslation     */
      for (metaph_end = Metaph + max_phones, n_start = n;
            n <= n_end && Metaph < metaph_end; ++n)
      {
            if (KSflag)
            {
                  KSflag = 0;
                  *Metaph++ = *n;
            }
            else
            {
                  /* Drop duplicates except for CC    */

                  if (*(n - 1) == *n && *n != 'C')
                        continue;

                  /* Check for F J L M N R  or first letter vowel */

                  if (same(*n) || (n == n_start && vowel(*n)))
                        *Metaph++ = *n;
                  else switch (*n)
                  {
                  case 'B':
                        if (n < n_end || *(n - 1) != 'M')
                              *Metaph++ = *n;
                        break;

                  case 'C':
                        if (*(n - 1) != 'S' || !frontv(*(n + 1)))
                        {
                              if ('I' == *(n + 1) && 'A' == *(n + 2))
                                    *Metaph++ = 'X';
                              else if (frontv(*(n + 1)))
                                    *Metaph++ = 'S';
                              else if ('H' == *(n + 1))
                                    *Metaph++ = ((n == n_start &&
                                          !vowel(*(n + 2))) ||
                                          'S' == *(n - 1)) ? 'K' : 'X';
                              else  *Metaph++ = 'K';
                        }
                        break;

                  case 'D':
                        *Metaph++ = ('G' == *(n + 1) && frontv(*(n + 2))) ?
                              'J' : 'T';
                        break;

                  case 'G':
                        if ((*(n + 1) != 'H' || vowel(*(n + 2))) &&
                              (*(n + 1) != 'N' || ((n + 1) < n_end &&
                              (*(n + 2) != 'E' || *(n + 3) != 'D'))) &&
                              (*(n - 1) != 'D' || !frontv(*(n + 1))))
                        {
                              *Metaph++ = (frontv(*(n + 1)) &&
                                    *(n + 2) != 'G') ? 'J' : 'K';
                        }
                        else if ('H' == *(n + 1) && !noghf(*(n - 3)) &&
                              *(n - 4) != 'H')
                        {
                              *Metaph++ = 'F';
                        }
                        break;

                  case 'H':
                        if (!varson(*(n - 1)) && (!vowel(*(n - 1)) ||
                              vowel(*(n + 1))))
                        {
                              *Metaph++ = 'H';
                        }
                        break;

                  case 'K':
                        if (*(n - 1) != 'C')
                              *Metaph++ = 'K';
                        break;

                  case 'P':
                        *Metaph++ = ('H' == *(n + 1)) ? 'F' : 'P';
                        break;

                  case 'Q':
                        *Metaph++ = 'K';
                        break;

                  case 'S':
                        *Metaph++ = ('H' == *(n + 1) || ('I' == *(n + 1) &&
                              ('O' == *(n + 2) || 'A' == *(n + 2)))) ?
                              'X' : 'S';
                        break;

                  case 'T':
                        if ('I' == *(n + 1) && ('O' == *(n + 2) ||
                              'A' == *(n + 2)))
                        {
                              *Metaph++ = 'X';
                        }
                        else if ('H' == *(n + 1))
                              *Metaph++ = 'O';
                        else if (*(n + 1) != 'C' || *(n + 2) != 'H')
                              *Metaph++ = 'T';
                        break;

                  case 'V':
                        *Metaph++ = 'F';
                        break;

                  case 'W':
                  case 'Y':
                        if (vowel(*(n + 1)))
                              *Metaph++ = *n;
                        break;

                  case 'X':
                        if (n == n_start)
                              *Metaph++ = 'S';
                        else
                        {
                              *Metaph++ = 'K';
                              KSflag = 1;
                        }
                        break;

                  case 'Z':
                        *Metaph++ = 'S';
                        break;
                  }
            }
      }

      *Metaph = '\0';
      sqlite3_free(ntrans);
      return strlen(metaph_start);
}


void metaphoneFunc (sqlite3_context *context, int argc, sqlite3_value **argv) {
    const unsigned char *input = sqlite3_value_text(argv[0]);
    int max_phones = 0;
    char *output; 
    int len;
    if (sqlite3_value_type(argv[0]) == SQLITE_NULL) {
        sqlite3_result_null(context);
        return;
    }
    if (argc > 1)
        max_phones = sqlite3_value_int(argv[1]);
    if (max_phones <= 0)
        max_phones = strlen((const char*) input);
    output = sqlite3_malloc((max_phones+1)*sizeof(char));
    len = metaphone((const char*) input, output, max_phones); 
    sqlite3_result_text(context, output, len, SQLITE_TRANSIENT);
}


#endif // SQLITE_EXTENSIONS_METAPHONE

#ifdef SQLITE_EXTENSIONS_LEVENSHTEIN

// from: https://github.com/mateusza/SQLite-Levenshtein/blob/master/src/levenshtein.c

#include <malloc.h>

#define LEVENSHTEIN_MAX_STRLEN 1024
// O(n*m) !!!

#define ___MIN___(a,b) (((a)<(b))?(a):(b))

static int levenshtein_distance(char* s1, char* s2 )
{
        int k,i,j,n,m,cost,*d,result;
        n=strlen(s1);
        m=strlen(s2);

        if ( n > LEVENSHTEIN_MAX_STRLEN || m > LEVENSHTEIN_MAX_STRLEN ){
                return -1;
        }

        if( n !=0 && m != 0){
                d=malloc((sizeof(int))*(++m)*(++n));
                for(k=0;k<n;k++){
                        d[k]=k;
                }
                for(k=0;k<m;k++){
                        d[k*n]=k;
                }
                for(i=1;i<n;i++){
                        for(j=1;j<m;j++){
                                if(s1[i-1]==s2[j-1])
                                        cost=0;
                                else
                                        cost=1;
                                d[j*n+i]=___MIN___( ___MIN___( d[(j-1)*n+i]+1, d[j*n+i-1]+1 ), d[(j-1)*n+i-1]+cost );
                        }
                }
                result=d[n*m-1];
                free(d);
                return result;
        }
        else {
                return (n>m)?n:m;
        }
}

void levenshteinFunc(sqlite3_context *context, int argc, sqlite3_value **argv )
{
        int result;

        if ( sqlite3_value_type( argv[0] ) == SQLITE_NULL || sqlite3_value_type( argv[1] ) == SQLITE_NULL ){
                sqlite3_result_null( context );
                return;
        }

        result = levenshtein_distance(
                (char*) sqlite3_value_text( argv[0] ),
                (char*) sqlite3_value_text( argv[1] )
        );

        if ( result == -1 ){
                // one argument too long
                sqlite3_result_null( context );
                return;
        }

        sqlite3_result_int( context, result );
}


#endif // SQLITE_EXTENSIONS_LEVENSHTEIN

#ifdef SQLITE_EXTENSIONS_JARO_WINKLER

// from: https://github.com/miguelvps/c/blob/master/jarowinkler.c

#include <string.h>

#define SCALING_FACTOR 0.1

static int max(int x, int y) {
    return x > y ? x : y;
}

static int min(int x, int y) {
    return x < y ? x : y;
}

double jaro_winkler_distance(const char *s, const char *a) {
    int i, j, l;
    int m = 0, t = 0;
    int sl = strlen(s);
    int al = strlen(a);
    int *sflags, *aflags;
    int range = max(0, max(sl, al) / 2 - 1);
    double dw;

    if (!sl || !al)
        return 0.0;

    sflags = (int*) calloc(sl, sizeof(int));
    aflags = (int*) calloc(al, sizeof(int));

    /* calloc should do...
    for (i = 0; i < al; i++)
        aflags[i] = 0;

    for (i = 0; i < sl; i++)
        sflags[i] = 0;
    */

    /* calculate matching characters */
    for (i = 0; i < al; i++) {
        for (j = max(i - range, 0), l = min(i + range + 1, sl); j < l; j++) {
            if (a[i] == s[j] && !sflags[j]) {
                sflags[j] = 1;
                aflags[i] = 1;
                m++;
                break;
            }
        }
    }

    if (!m) {
        free(sflags); free(aflags);
        return 0.0;
    }
    /* calculate character transpositions */
    l = 0;
    for (i = 0; i < al; i++) {
        if (aflags[i] == 1) {
            for (j = l; j < sl; j++) {
                if (sflags[j] == 1) {
                    l = j + 1;
                    break;
                }
            }
            if (a[i] != s[j])
                t++;
        }
    }
    t /= 2;

    /* Jaro distance */
    dw = (((double)m / sl) + ((double)m / al) + ((double)(m - t) / m)) / 3.0;

    /* calculate common string prefix up to 4 chars */
    l = 0;
    for (i = 0; i < min(min(sl, al), 4); i++)
        if (s[i] == a[i])
            l++;

    /* Jaro-Winkler distance */
    dw = dw + (l * SCALING_FACTOR * (1 - dw));

    free(sflags); free(aflags);
    return dw;
}

void jaroWinklerFunc(sqlite3_context *context, int argc, sqlite3_value **argv )
{
        double result;

        if ( sqlite3_value_type( argv[0] ) == SQLITE_NULL || sqlite3_value_type( argv[1] ) == SQLITE_NULL ){
                sqlite3_result_null( context );
                return;
        }

        result = jaro_winkler_distance(
                (char*) sqlite3_value_text( argv[0] ),
                (char*) sqlite3_value_text( argv[1] )
        );

        if ( result == -1 ){
                // one argument too long
                sqlite3_result_null( context );
                return;
        }

        sqlite3_result_double( context, result );
}

#endif // SQLITE_EXTENSIONS_JARO_WINKLER
