# Manual changes

If, for some reason, FetchRemote and/or patching fails, then

- set `option(SQLITE3_PCRE_FETCH "Fetch pcre sources from GitHub and patch" OFF)`
- `git clone https://github.com/ralight/sqlite3-pcre.git`
- `git clone https://github.com/nektro/pcre-8.45.git pcre-git`
- Delete or rename pcre-git/config.h
- clear cache
