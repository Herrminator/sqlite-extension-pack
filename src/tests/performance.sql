select load_extension('extension-functions');
select load_extension('sqlite3-pcre');

create temporary table out (
    t text
);

create temporary view generator as
  with recursive gen(n, t) as (
      VALUES(1, 'The longer, the better. The quick brown fox jumped over the lazy dog')
      UNION ALL SELECT n + 1, t FROM gen WHERE n < 10000000
  )
  select * from gen
;

.changes on

.timer on
insert into out select metaphone(t) as m from generator
where m = 'NONONO' and n < 0 -- avoid actual insert
;
.timer off

.timer on
insert into out select t from generator
where t regexp('.*fox.*y') and n < 0
;
.timer off