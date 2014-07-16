#!/usr/bin/env python

import sys
import optparse
import sqlite3
import base64
import time

def getId(db,table, name, value = "", ):
  c = conn.cursor()
  c.execute ("select id from {0} where name = \"{1}\";".format(table,name))
  id = None
  try:
    id = c.fetchone()[0]
  except:
    pass
  if id is not None:
    return id
  elif value != "":
    c.execute("insert into {0} (name) values (\"{1}\");".format(table, value))
    conn.commit()
    c.execute ("select id from {0} where name = \"{1}\";".format(table,name))
    id = c.fetchone()[0]
    return id
  else:
    raise Exception("cannot insert value \"{0}\" into \"{1}\"".format(value, table))

parser = optparse.OptionParser();

parser.add_option("--platform",dest="platform", help="Build platform",metavar="PLATFORM", action="store", default="")
parser.add_option("--generator",dest="generator", help="Generator",metavar="GENERATOR", action="store", default="")
parser.add_option("--version",dest="version", help="Generator's version",metavar="VERSION", action="store", default="")
parser.add_option("--release",dest="release", help="LCG release",metavar="RELEASE", action="store", default="")
parser.add_option("--analysis",dest="analysis", help="Analysis",metavar="ANALYSIS", action="store", default="")
parser.add_option("--files",dest="files", help="Files to store in DB, delimited by ','",metavar="FILES", action="store", default="")
parser.add_option("--comment",dest="comment", help="Comment",metavar="COMMENT", action="store", default="")
(option, args) = parser.parse_args()

try:
  dbname = args[0]
except:
  raise Exception ("DB not found")
conn = sqlite3.connect(dbname)
# create tables if not exists
tmpsql = """
CREATE TABLE IF NOT EXISTS analysis(id INTEGER PRIMARY KEY AUTOINCREMENT, name CHAR NOT NULL);
CREATE TABLE IF NOT EXISTS build(id INTEGER PRIMARY KEY AUTOINCREMENT, release CHAR NOT NULL, generator INTEGER NOT NULL, analysis INTEGER NOT NULL, platform INTEGER NOT NULL, files CHAR, comment CHAR);
CREATE TABLE IF NOT EXISTS files(id INTEGER PRIMARY KEY AUTOINCREMENT, name CHAR NOT NULL, data BLOB, date CHAR);
CREATE TABLE IF NOT EXISTS generators(id INTEGER PRIMARY KEY AUTOINCREMENT, name CHAR NOT NULL, version CHAR NOT NULL);
CREATE TABLE IF NOT EXISTS platform(id INTEGER PRIMARY KEY AUTOINCREMENT, name CHAR NOT NULL);"""
for sql in tmpsql.split(";"):
  conn.cursor().execute(sql)
del tmpsql
# end
analysis_id = getId(conn,"analysis",option.analysis, option.analysis)
platform_id = getId(conn,"platform",option.platform, option.platform)

# process generators ...
c = conn.cursor()
c.execute ("select id, name, version from generators where name = \"{0}\" and version = \"{1}\";".format(option.generator, option.version))
gen_id = None
try:
  gen_id = c.fetchone()[0]
except:
  c.execute("insert into generators (name, version) values (\"{0}\",\"{1}\");".format(option.generator, option.version))
  conn.commit()
  c.execute ("select id, name, version from generators where name = \"{0}\" and version = \"{1}\";".format(option.generator, option.version))
  gen_id = c.fetchone()[0]

# process files ...
files_ids = []
add_time = time.time()
for f in (option.files).split(","):
  try:
    with open(f, "rb") as file:
      encoded_file = base64.b64encode(file.read())
    if ".yoda" in f:
      f = "result.yoda"
    c.execute("insert into files (name, data, date) values (\"{0}\",\"{1}\",\"{2}\");".format(f, encoded_file, add_time))
    conn.commit()
    c.execute("select id from files where name = \"{0}\" and data = \"{1}\" and date = \"{2}\";".format(f, encoded_file, add_time))
    files_ids.append(str(c.fetchone()[0]))
  except:
    raise Exception("Cannot process file \"{0}\"".format(f))
# CREATE TABLE build(id INTEGER PRIMARY KEY AUTOINCREMENT, release CHAR NOT NULL, generator INTEGER NOT NULL, analysis INTEGER NOT NULL, platform INTEGER NOT NULL, files CHAR, comment CHAR);
sql =  "insert into build (release,generator, analysis, platform, files, comment) values (\"{0}\",{1},{2},{3},\"{4}\",\"{5}\");".format(str(option.release), gen_id, analysis_id, platform_id, ",".join(files_ids), option.comment)
c.execute(sql)
conn.commit()
conn.close()
