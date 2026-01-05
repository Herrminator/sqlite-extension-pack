.print '* Testing stmt'

/* sqlite_stmt is precompiled in standard shell
.testcase 'stmt-precompiled'
  select * from pragma_module_list() where name = 'sqlite_stmt';
.check ''
*/

.testcase 'stmt-load'
  select load_extension('sqlite3-stmt');
.check ''

.testcase 'stmt-01'
  select * from sqlite_stmt;
.check 'select [*] from sqlite_stmt;|11|1|1|0|0|0|0|0|1|#'
