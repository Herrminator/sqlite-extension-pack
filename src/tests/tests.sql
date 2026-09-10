.bail off
begin;
.read 'test-extension-functions.sql'
.read 'test-tjutil.sql'
.read 'test-rot13.sql'
.read 'test-pcre.sql'
.read 'test-lua.sql'
.read 'test-series.sql'
.read 'test-stmt.sql'
.read 'test-spellfix1.sql'
commit;
