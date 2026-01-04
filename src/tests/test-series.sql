.print '* Testing series'

.testcase 'series-load'
  select load_extension('sqlite3-series');
.check ''

.testcase 'series-01'
  select * from generate_series(0, 10, 2);
.check '0 2 4 6 8 10'
