.print '* Testing pcre'

.load 'sqlite3-pcre'

create temporary view pcre_values as
  values ('foobar'), ('foo'), ('bar'), ('raboof')
;

.testcase 'pcre-01'
  select column1 from pcre_values where column1 regexp 'o+';
  select column1 from pcre_values where column1 regexp '^f.*o$';
  select column1 from pcre_values where column1 regexp '^r?(ab|ba)';
.check 'foobar foo raboof foo bar raboof'
