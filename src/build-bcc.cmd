@echo off
call bccenv
rem make clean extension-functions.dll
rem vcexpress sqlite_extensions.sln /build %*
if not exist ..\build\bcc mkdir ..\build\bcc
if not defined SQLITE_LUA_SOURCE set "SQLITE_LUA_SOURCE=%~dp0dependencies\sqlite-lua"
if not defined LUA_SOURCE set "LUA_SOURCE=%~dp0dependencies\lua"

make "-DLUA_SOURCE=%LUA_SOURCE%" "-DSQLITE_LUA_SOURCE=%SQLITE_LUA_SOURCE%" -f makefile.bcc %*
rem del *.map
