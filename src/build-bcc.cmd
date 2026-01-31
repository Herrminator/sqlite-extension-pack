@echo off
call bccenv
rem make clean extension-functions.dll
rem vcexpress sqlite_extensions.sln /build %*
if not exist ..\build\bcc mkdir ..\build\bcc
rem HACK ALERT: Now that we let CMake download the sources, we have to assume it built first...
if not defined SQLITE_LUA_SOURCE set "SQLITE_LUA_SOURCE=%~dp0..\build\x86-release\_deps\sqlite-lua-src"
if not defined LUA_SOURCE        set "LUA_SOURCE=%~dp0..\build\x86-release\_deps\lua-src"

make "-DLUA_SOURCE=%LUA_SOURCE%" "-DSQLITE_LUA_SOURCE=%SQLITE_LUA_SOURCE%" -f makefile.bcc %*
rem del *.map
