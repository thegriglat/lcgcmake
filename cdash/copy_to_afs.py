#!/usr/bin/env python
# This script copies build results to AFS in case of nightlies

import os
import datetime
import shutil
import subprocess
import sys
import errno
from optparse import OptionParser

def today():
    return datetime.date.today().strftime('%a')

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

def ensureProperCompiler(root, dirs, compilerdir):
    """remove all gcc compilers except for what is given by CXX in the environment """    
    compilervers = compilerdir.split("gcc")[1].split("/")[1]
    if "/gcc/" in root and not compilervers in root:
      dirs[:] = []
 
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

def createInstallArea(basepath,platform,lcgversion,compilerdir):
  # create InstallArea dirs
  installarea = os.path.join(basepath,"LCGCMT",lcgversion,"InstallArea",platform)
  if os.path.exists(installarea):
    shutil.rmtree(installarea)
  os.makedirs(installarea)
  os.makedirs(os.path.join(installarea,"lib"))
  os.makedirs(os.path.join(installarea,"bin"))
  print installarea, "created"

  # collect all libs and bins for the given platform
  libs = {}
  bins = {}
  for root, dirs, files in os.walk(basepath,followlinks=True):
     removeBlackListed(dirs)
     ensureProperCompiler(root,dirs,compilerdir)
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

  platform = os.environ['PLATFORM']

  if ((platform.find("ubuntu") != -1) or (platform.find("mac") != -1)):
      print "Avoiding copy to AFS in this platform", platform
      sys.exit(0)
  else:
      cmd = "kinit sftnight@CERN.CH -5 -V -k -t /ec/conf/sftnight.keytab"
      os.system(cmd)

  # extract command line parameters
  usage = "usage: %prog slotname workdir"
  parser = OptionParser(usage)
  parser.add_option('-t', '--targetbase', action='store', 
                     dest='targetbase', help='basepath to copy to',
                     default="/afs/cern.ch/sw/lcg/app/nightlies" 
                    )

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

  thisdir = os.path.dirname(os.path.abspath(__file__))
#  platform = os.environ['PLATFORM']
  compiler = os.environ['CXX']
  compilerdir = compiler.split("bin")[0]

  # define source and target  
  sourcedir = "%s/%s-install" %(workdir,platform)
  targetdir = os.path.join(options.targetbase,slotname,today())

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
    package_source = os.path.join(sourcedir,package)
    package_destination = os.path.join(targetdir,package)
    # clean the destination
    if os.path.islink(package_destination):
      os.unlink(package_destination)
    elif os.path.isdir(package_destination):
      shutil.rmtree(package_destination)
    # link or copy to destination
    if os.path.islink(package_source):
      print "[%i/%i] Linking %s to %s" %(counter, total, package, targetdir)
      try:
        os.makedirs(os.path.dirname(package_destination))
      except OSError as exc:
        if exc.errno == errno.EEXIST and os.path.isdir(os.path.dirname(package_destination)):
          pass
        else:
          print "ERROR: Makedirs %s failed." %(os.path.dirname(package_destination))
      try:
        os.symlink(os.readlink(package_source), package_destination)
      except (IOError, os.error) as why:
        print str(why)
      except:
        print "ERROR: Linking %s failed." %(package)
    else:
      print "[%i/%i] Copying %s to %s" %(counter, total, package, targetdir)
      try:
        shutil.copytree(package_source, package_destination, symlinks=True)
      except (IOError, os.error) as why:
        print str(why)
      except shutil.Error as err:
        print err
      except:
        print "ERROR: Copying of %s failed." %(package)

  # copy LCGCMT explicitly
  command = "rsync -au --no-g %s/LCGCMT/ %s/LCGCMT" %(sourcedir, targetdir)
  print subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.read()  

  #create InstallArea for ATLAS
  createInstallArea(targetdir,platform,"LCGCMT_%s"%slotname,compilerdir) 
    
  #create release summary file for LHCb
  command = "%s/extract_LCG_summary.py %s %s %s RELEASE" %(thisdir,targetdir,platform,slotname)
  print subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.read()

  #create symlink to gcc
  if not os.path.exists(targetdir+'/gcc'):
    os.symlink('/afs/cern.ch/sw/lcg/contrib/gcc',targetdir+'/gcc')

    
  
