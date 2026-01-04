@echo off
set EPATH=
set SPATH=
set s=%1
if not defined s set s=pl86
rem Production CLI/ Legacy
if "'%s%'"=="'pl86'" set "SPATH=..\..\.."     & set "EPATH=..\..\Release"
if "'%s%'"=="'pl64'" set "SPATH=..\..\..\x64" & set "EPATH=..\..\x64\Release.del"
rem Production CLI / current
if "'%s%'"=="'pc86'" set "SPATH=..\..\.."     & set "EPATH=..\..\Release\x86\bin"
if "'%s%'"=="'pd86'" set "SPATH=..\..\.."     & set "EPATH=..\..\Debug\x86\bin"
if "'%s%'"=="'pc64'" set "SPATH=..\..\..\x64" & set "EPATH=..\..\Release\x64\bin"
if "'%s%'"=="'pd64'" set "SPATH=..\..\..\x64" & set "EPATH=..\..\Debug\x64\bin"
if "'%s%'"=="'er64'" set "SPATH=..\..\..\x64"
rem Test CLI / current
if "'%s%'"=="'cc86'" set "SPATH=..\..\Release\x86\bin"
if "'%s%'"=="'cd86'" set "SPATH=..\..\Debug\x86\bin"
if "'%s%'"=="'cc64'" set "SPATH=..\..\Release\x64\bin"
if "'%s%'"=="'cd64'" set "SPATH=..\..\Debug\x64\bin"
rem since https://www.sqlite.org/changes.html#version_3_36_0 REGEXP is included in the CLI!
: set "SPATH=..\..\..\x64"

set PATH=%SPATH%;%EPATH%;%PATH%


where sqlite3 sqlite3-pcre.dll
sqlite3 -version
