.print '* Testing rot13'

.load 'sqlite3-rot13'

create temporary view rot13_values as
  values ('foobar'), ('foo'), ('bar'), ('raboof')
;

.testcase 'rot13-01'
  select column1, rot13(column1) from rot13_values
  order by column1
  ;
.check 'bar|one foo|sbb foobar|sbbone raboof|enobbs'

.testcase 'rot13-02'
  select column1, rot13(column1) from rot13_values
  order by column1 collate rot13
  ;
.check 'raboof|enobbs bar|one foo|sbb foobar|sbbone'
