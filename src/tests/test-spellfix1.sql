.print '* Testing spellfix1'

.testcase 'spellfix1-load'
  select load_extension('sqlite3-spellfix1');
.check ''

create virtual table temp.demo using spellfix1;

insert into temp.demo(word) values ('Kennesaw'), ('Atlanta'), ('Savannah');

.testcase 'spellfix1-match'
  select word from temp.demo where word match 'kennasaw' and top=1;
.check 'Kennesaw'

.testcase 'spellfix1-editdist3-relative'
  select editdist3('Kennesaw', 'Kennasaw') < editdist3('Kennesaw', 'Atlanta');
.check '1'

.testcase 'spellfix1-editdist3-identical'
  select editdist3('Kennesaw', 'Kennesaw');
.check '0'
