@echo off
set PATH=%~dp0..\..\build\x64-release;%PATH%

set HELLO=Hello World!

call ..\..\..\x64\sqlite3 -batch tests.db3 ".read tests.sql"
echo rc=%ERRORLEVEL%
