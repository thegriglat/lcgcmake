#!/usr/bin/env python

import sys, shutil, os
from os import path
from datetime import datetime, timedelta

two_days_ago = datetime.now() - timedelta(hours=2)
work_directory = "/build/jenkins/workspace"

for dirs in os.listdir(work_directory):
    if os.path.isfile(dirs):
        pass
    else:
        fullpath = work_directory+"/"+dirs
        check_file = fullpath+"/controlfile"

        if os.path.exists(check_file):
            filetime = datetime.fromtimestamp(path.getctime(check_file))
            print "the controlfile exists at:  ", fullpath
            if filetime < two_days_ago:
                print "controlFile is more than two days old"
                for root, dirs, files in os.walk(fullpath):
                    for f in files:
                        os.unlink(os.path.join(root, f))
                    for d in dirs:
                        shutil.rmtree(os.path.join(root, d))
            else:
                print "controlFile is less than two days old. Nothing to remove"  
