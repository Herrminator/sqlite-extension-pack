#!/bin/bash
export HELLO="Hello World!"

exec sqlite3 -batch tests.db3 ".read tests.sql"
