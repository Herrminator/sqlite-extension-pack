.print '* Testing extension-functions'

.load 'sqlite3-extension-functions'

.testcase 'math-01'
  select log10(1000);
  select pi();
.check '3.0 3.14159265358979'

.testcase 'string-01'
  select replicate('A', 3);
  select reverse('foobar');
.check 'AAA raboof'

create temporary view test_values(left, right)
  as values ('foo', 'foe'), ('bar', 'bore'), ('foobar', 'fuber');

.testcase 'soundex-01'
  select soundex(left), soundex(right) from test_values;
.check 'F000|F000 B600|B600 F160|F160'

.testcase 'levenshtein-01'
  -- number of edits
  select levenshtein_distance(left, right) from test_values;
.check '1 2 3'

.testcase 'jaro-winkler-01'
  select jaro_winkler_distance(left, right) from test_values;
.check '0.822222222222222 0.777777777777778 0.73'

.testcase 'metaphone-01'
  select metaphone(left), metaphone(right) from test_values;
.check 'F|F BR|BR FBR|FBR'

.testcase 'metaphone-02'
  with test(left, right) as
    -- This causes problems if metaphone is compiled with -O2
    (values ('Right Now', 'Right On'))
  select metaphone(left), metaphone(right) from test;
.check 'RFTN|RFTN'
    -- The wrong result would be: .check 'RTNW|RTN'
