#!/usr/bin/env python3
import os, sqlite3, time
from contextlib import contextmanager

os.environ["PATH"] += os.pathsep + r"C:\Users\johlet\Develop\SQLite\extensions\x64\Release"


@contextmanager
def timer():
    start = time.perf_counter()
    yield lambda: time.perf_counter() - start
    print(f'Time: {time.perf_counter() - start:.3f} seconds')


# see `tests/performance.sql`

db = sqlite3.connect(":memory:")
db.enable_load_extension(True)


cur = db.execute("select * from pragma_function_list where name = 'metaphone'")
print(cur.fetchall())

db.load_extension("extension-functions")

cur = db.execute("select * from pragma_function_list where name = 'metaphone'")
print(cur.fetchall())

db.executescript(
    """
    create temporary table out
    (
        t text
    );

    create temporary view generator as
    with recursive gen(n, t) as (VALUES (1,
                                         'The longer, the better. The quick brown fox jumped over the lazy dog')
                                 UNION ALL
                                 SELECT n + 1, t
                                 FROM gen
                                 WHERE n < 10000000)
    select *
    from gen
    ;
    """)

with timer():
    db.executescript(
        """
        insert into out
        select metaphone(t) as m
        from generator
        where m = 'NONONO'
          and n < 0 -- avoid actual insert
        ;
        """)

cur = db.execute("select * from pragma_function_list where name = 'regexp'")
print(cur.fetchall())

db.load_extension("sqlite3-pcre")

cur = db.execute("select * from pragma_function_list where name = 'regexp'")
print(cur.fetchall())

with timer():
    db.executescript(
        """
        insert into out
        select t
        from generator
        where t regexp ('.*fox.*y')
          and n < 0
        """)
