@echo off
call bccenv
rem make clean extension-functions.dll
rem vcexpress sqlite_extensions.sln /build %*
if not exist ..\build\bcc mkdir ..\build\bcc
make -f makefile.bcc %*
rem del *.map
