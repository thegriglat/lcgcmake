#!/usr/bin/env python
# This script copies build results to AFS in case of nightlies

import os
import datetime
import subprocess
import sys

def today():
    return datetime.date.today().strftime('%a')

def get_platform():
    return subprocess.Popen("cd /ec/lcg-scripts/; cmake -P /ec/lcg-scripts/get_platform.cmake; cd $OLDPWD", shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.read().rstrip()

##########################
if __name__ == "__main__":

  # first we check whether we want to do anything at all
  slotname = os.environ.get('SLOTNAME')
  if slotname in (None, "none") :
    print "skipping AFS install step"
    sys.exit(0)

  # define source and target  
  workdir = os.environ['WORKDIR']
  sourcedir = "%s/%s-install" %(workdir,get_platform())
  targetdir = "/afs/cern.ch/sw/lcg/app/nightlies/%s/%s" %(slotname,today())
  command = "rsync -au --no-g %s/ %s" %(sourcedir,targetdir)
  print "Executing %s" %command
  print subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.read()
  command = "touch %s/isDone-%s" %(targetdir,get_platform())
  print subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.read()
    


    
  
