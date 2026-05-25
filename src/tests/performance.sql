select * from pragma_function_list where name = 'metaphone';
select load_extension('extension-functions');
select * from pragma_function_list where name = 'metaphone';

drop table if exists out;
create temporary table out (
    t text
);

drop view if exists generator;
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

-- Use the CLI regexp (built-in since 3.36.0 (06/2021))
select * from pragma_function_list where name = 'regexp';
.timer on
insert into out select t from generator
where t regexp('.*fox.*y') and n < 0
;
.timer off

select load_extension('sqlite3-pcre');
select * from pragma_function_list where name = 'regexp';

.timer on
insert into out select t from generator
where t regexp('.*fox.*y') and n < 0
;
.timer off
