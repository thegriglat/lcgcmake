#!/usr/bin/env python

import shutil
from os import path, listdir, getcwd, rmdir
from datetime import datetime, timedelta
from optparse import OptionParser

#---Globals-----------------------------------------------------------
mindate = 0
controlfile = 'controlfile'

def ctime(filename):
   return datetime.fromtimestamp(path.getctime(filename))

def find_dirs_to_clean(cdir, depth):
   global mindate, controlfile
   result = []
   check_file = path.join(cdir,controlfile)
   if path.exists(check_file) and ctime(check_file) < mindate:
      result += [cdir]
   elif depth <= 0:
      pass
   else:
      for d in listdir(cdir):
         fulldir = path.join(cdir,d)
         if path.isdir(fulldir):
            result += find_dirs_to_clean(fulldir, depth-1)
   return result

if __name__ == "__main__":
   usage = "usage: %prog rootdir"
   parser = OptionParser(usage)
   parser.add_option('-a', '--age', type='int',
                     dest='min_age', help='minimal age in hours (default 48)',
                     default=48)
   parser.add_option('-d', '--depth', type='int',
                     dest='max_depth', help='max depth in directory tree',
                     default=12)

   (options, args) = parser.parse_args()
   if len(args) == 0: rootdir = getcwd()
   else:              rootdir = args[0]

   mindate = datetime.now() - timedelta(hours = options.min_age)
   dirs_to_clean = find_dirs_to_clean(rootdir, options.max_depth)
   for d in dirs_to_clean:
      print 'Removing directory %s, built on %s' %(d,ctime(path.join(d,controlfile)))
      shutil.rmtree(d)
      #prune empty directories
      p = path.dirname(d)
      while p != rootdir :
         if not listdir(p):
            print 'Removing empty directory %s' % (p)
            rmdir(p)
         p = path.dirname(p)


