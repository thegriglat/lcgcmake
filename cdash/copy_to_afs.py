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

# part to handle an InstallArea inside LCGCMT with the following structure:
# LCGCMT/<version>/InstallArea/<platform>/
#    bin/
#    lib/
# with symlinks to all binaries and .so files defined by that LCGCMT nightly build
blacklist = ['src','sources','boost','share','include','.svn','doc',"MCGenerators",'logs','etc','CMT']
def removeBlackListed(dirs):
    for item in blacklist:
      try:
        dirs.remove(item)
      except ValueError:
        pass

def identifyLib(root,aFile,platform):
    if (root.endswith("lib") or root.endswith("lib64")):
      if ".so" in aFile or aFile.endswith("rootmap"):
        if platform in root:
          return True
    return False
      
def identifyBin(root,aFile,platform):
    if root.endswith("bin"):
      if platform in root:
        return True
    return False


def createInstallArea(basepath,platform,lcgversion):
  # create InstallArea dirs
  installarea = os.path.join(basepath,"LCGCMT",lcgversion,"InstallArea",platform)
  if not os.path.exists(installarea):
    os.makedirs(installarea)
    os.makedirs(os.path.join(installarea,"lib"))
    os.makedirs(os.path.join(installarea,"bin"))
  print installarea, "created"

  # collect all libs and bins for the given platform
  libs = {}
  bins = {}
  for root, dirs, files in os.walk(basepath):
     # remove blacklisted subdirs
     removeBlackListed(dirs)
     for afile in files:
       if identifyLib(root,afile,platform): 
         libs[afile] = os.path.join(root,afile)
       elif identifyBin(root,afile,platform):
         bins[afile] = os.path.join(root,afile)

  # create symlinks
  os.chdir(os.path.join(installarea,"lib"))
  for key, value in libs.iteritems():
    destination = os.path.relpath(value)
    if not os.path.exists(key):
      os.symlink(destination,key)
      print "Creating %s" %(destination)
      # special hack for ATLAS and Boost
      if "libboost" in key and "-d-" in key:
        newname = key.replace("-d-","-")
        os.symlink(destination,newname)
        print "Creating %s" %(destination)
  os.chdir(os.path.join(installarea,"bin"))
  for key, value in bins.iteritems():
    destination = os.path.relpath(value)
    if not os.path.exists(key):   
       os.symlink(destination,key)
       print "Creating %s" %(destination) 



##########################
if __name__ == "__main__":

  # first we check whether we want to do anything at all
  slotname = os.environ.get('SLOTNAME')
  if slotname in (None, "none") :
    print "skipping AFS install step"
    sys.exit(0)
  lcgversion = os.environ.get('LCG_VERSION')  

  # define source and target  
  workdir = os.environ['WORKDIR']
  sourcedir = "%s/%s-install" %(workdir,get_platform())
  targetdir = "/afs/cern.ch/sw/lcg/app/nightlies/%s/%s" %(slotname,today())
  command = "rsync -au --no-g %s/ %s" %(sourcedir,targetdir)
  print "Executing %s" %command
  print subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.read()

  #create InstallArea for ATLAS
  createInstallArea(targetdir,get_platform(),"LCGCMT_%s"%lcgversion ) #TODO: make version dynamic 
    
  #create release summary file for LHCb
  command = "/ec/lcg-scripts/extract_LCG_summary.py %s %s %s" %(targetdir,get_platform(),lcgversion)
  print subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.read()

  #create symlink to gcc
  command = "ln -s /afs/cern.ch/sw/lcg/contrib/gcc %s/gcc" %targetdir
  print subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.read()

  # declare as done
  command = "touch %s/isDone-%s" %(targetdir,get_platform())
  print subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.read()

    
  
