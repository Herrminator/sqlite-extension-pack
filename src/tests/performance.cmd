@echo off
@call .\select.cmd %1

call sqlite3 -batch ":memory:" ".read 'performance.sql'"
