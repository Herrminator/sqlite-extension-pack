#!/bin/bash
sqlite3=${1-sqlite3}
arch=${2-x86}

"$sqlite3" -batch ":memory:" "pragma compile_options" | grep -Ev '^COMPILER=' \
    | sed -E 's/(.*$)/SQLITE_\1/' \
    > "sqlite3.${arch}.options"
