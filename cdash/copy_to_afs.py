#!/usr/bin/env python
# This script copies build results to AFS in case of nightlies

import os
import datetime
import shutil
import subprocess
import sys
from optparse import OptionParser

def today():
    return datetime.date.today().strftime('%a')

def get_platform(workdir):
    """Guess the platform from the directories WORKDIR."""
    for item in os.listdir(workdir):
      if "-install" in item:
        return item.split("-install")[0]

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

  # extract command line parameters
  usage = "usage: %prog slotname workdir"
  parser = OptionParser(usage)
  (options, args) = parser.parse_args()    
  if len(args) == 0:
    # option for backwards compatibility; to be dropped once dev2 and dev4 use new scripts
    slotname = os.environ.get('SLOTNAME')
    workdir = os.environ['WORKDIR']
    if slotname in (None, "none") :
      print "skipping AFS install step"
      sys.exit(0)
  elif len(args) != 2:
    parser.error("incorrect number of arguments")
  else:
    slotname = args[0]
    workdir =  args[1]

  platform = get_platform(workdir)

  # define source and target  
  sourcedir = "%s/%s-install" %(workdir,platform)
  targetdir = "/afs/cern.ch/sw/lcg/app/nightlies/%s/%s" %(slotname,today())

  # find out which directories to copy
  dirs_to_copy=[]
  for name in os.listdir(sourcedir):
    fullname = os.path.join(sourcedir,name)
    if name in ["MCGenerators","Grid"]:
      for package in os.listdir(fullname):
        packagedir = os.path.join(fullname,package)
        for versiondir in os.listdir(packagedir):
          relative_platformdir = os.path.join(name,package,versiondir,platform)
          dirs_to_copy.append(relative_platformdir)
    elif name in ["distribution","lhapdf6sets","lhapdfsets"]:
      pass # => is blacklisted 
    elif os.path.isdir(fullname):
      for versiondir in os.listdir(fullname):
        relative_platformdir = os.path.join(name,versiondir,platform)
        dirs_to_copy.append(relative_platformdir)

  # actual copy operation
  print "Start copying %i packages" %len(dirs_to_copy)
  counter = 0
  total = len(dirs_to_copy)
  for package in dirs_to_copy:
    counter += 1
    print "Copying %s to AFS. [%i / %i]" %(package, counter, total)
    package_source = os.path.join(sourcedir,package)
    package_destination = os.path.join(targetdir,package)
    print "Copying %s to %s" %(package_source,package_destination)
    shutil.copytree(package_source,package_destination)
  
  #create InstallArea for ATLAS
  createInstallArea(targetdir,platform,"LCGCMT_%s"%slotname) 
    
  #create release summary file for LHCb
  command = "%s/lcg-scripts/extract_LCG_summary.py %s %s %s" %(workdir,targetdir,platform,slotname)
  print subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.read()

  #create symlink to gcc
  command = "ln -s /afs/cern.ch/sw/lcg/contrib/gcc %s/gcc" %targetdir
  print subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.read()

  # declare as done
  command = "touch %s/isDone-%s" %(targetdir,platform)
  print subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.read()

    
  
