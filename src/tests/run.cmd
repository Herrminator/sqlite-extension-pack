@echo off
set PATH=%~dp0..\..\build\x86-release;%PATH%

set HELLO=Hello World!

call ..\..\..\sqlite3 -batch tests.db3 ".read tests.sql"
echo rc=%ERRORLEVEL%
