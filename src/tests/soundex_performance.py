#!/usr/bin/python3
# -*- coding: utf-8 -*-
import os, sqlite3, locale, time

ITER = 1000000
STMT = "select soundex('Öresund')"

# avoid unicode error if not patched...
# print(locale.setlocale(locale.LC_ALL, "en_US.utf-8"))
print(locale.setlocale(locale.LC_ALL, "C"))

db = sqlite3.connect("file:tests.db3?mode=ro", uri=True)
db.enable_load_extension(True)
db.load_extension(r"extension-functions")

t = time.time()
for i in range(ITER):
  cur = db.execute(STMT)
  cur.fetchall()

t = (time.time() - t) / ITER * 1000

print(f"{t} ms/call")
