#pragma once

#if defined(_MSC_VER) || defined(__BORLANDC__)

#include "sqlite3.h"

typedef sqlite3_int64     int64_t;
typedef unsigned __int8   uint8_t;
typedef unsigned __int16  uint16_t;
#if !defined(__BORLANDC__)
typedef unsigned __int32  uint32_t ;
#endif

#else

#error "You probably don't need this file. Please rename!"

#endif
