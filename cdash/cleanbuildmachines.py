#!/usr/bin/env python

import sys, shutil, os
from os import path
from datetime import datetime, timedelta
from optparse import OptionParser

mindate = 0
controlfile = 'controlfile'

def ctime(filename):
   return datetime.fromtimestamp(path.getctime(filename))

def find_dirs_to_clean(cdir, depth):
   global mindate, controlfile
   check_file = os.path.join(cdir,controlfile)
   if os.path.exists(check_file):
      if ctime(check_file) < mindate :
         return [cdir]
      else:
         return []
   elif depth <= 0:
      return []
   else:
      result = []
      for d in os.listdir(cdir):
         fulldir = os.path.join(cdir,d)
         if os.path.isdir(fulldir):
            result += find_dirs_to_clean(fulldir, depth-1)
      return result

if __name__ == "__main__":
   # extract command line parameters
   usage = "usage: %prog rootdir"
   parser = OptionParser(usage)
   parser.add_option('-a', '--age', type='int',
                     dest='min_age', help='minimal age in hours (default 48)',
                     default=48)
   parser.add_option('-d', '--depth', type='int',
                     dest='max_depth', help='max depth in directory tree',
                     default=10)

   (options, args) = parser.parse_args()
   if len(args) == 0: rootdir = os.getcwd()
   else:              rootdir = args[0]

   mindate = datetime.now() - timedelta(hours = options.min_age)
   dirs_to_clean = find_dirs_to_clean(rootdir, options.max_depth)
   for d in dirs_to_clean:
      print 'Removing directory %s, built on %s' %(d,ctime(os.path.join(d,controlfile)))
      shutil.rmtree(d)
