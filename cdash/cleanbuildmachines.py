#!/usr/bin/env python

import sys, shutil, os
from os import path
from datetime import datetime, timedelta

two_days_ago = datetime.now() - timedelta(days=2)
check_file = "controlfile"
work_directory = os.environ["WORKSPACE"]

if os.path.exists(check_file):
    print  "the controlfile exists"
else:
    print "controlfile does not exist, we stop here"
    sys.exit(-1)

filetime = datetime.fromtimestamp(path.getctime(check_file))


if filetime < two_days_ago:
  print "controlFile is more than two days old"
  for root, dirs, files in os.walk(work_directory):
      for f in files:
          os.unlink(os.path.join(root, f))
      for d in dirs:
          shutil.rmtree(os.path.join(root, d))
else:
  print "controlFile is less than two days old. Nothing to remove"  
