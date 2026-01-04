@echo off
set PATH=..\Release;%PATH%
call sqlite3 -batch ":memory:" ".read tryme.sql"
