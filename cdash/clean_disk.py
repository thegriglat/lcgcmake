#!/usr/bin/env python
# This script makes sure that there is always enough space for doing builds on the build machines.
# If a certain size fraction is full, it starts deleting the oldest builds. 
# TODO: It never deletes the last two builds, but exits w/ error in that case.

import os
import sys
import shutil

def free_percentage(path):
  statvfs   = os.statvfs(path)
  size      =  statvfs.f_frsize * statvfs.f_blocks     
  available = statvfs.f_frsize * statvfs.f_bavail  
  percentage = available * 100./size
  return percentage

def get_oldest_build(directory):
    """get the oldest directory of the type project-slot-jobid. 
     Oldest is defined in terms of lowest id and not date."""
    result = os.listdir(directory)
    result = [os.path.join(directory,item) for item in result if os.path.isdir( os.path.join(directory,item) ) and item.count("-")==2]
    def extract_id(name):
      return int(name.split("-")[-1])
    result.sort(key=extract_id) 
    print "Old builds: %s" %result
    if len(result) != 0:
      return result[0]
    return None

required_free_percentage = 20 

##########################
if __name__ == "__main__":

  if len(sys.argv) != 2:
    print "Please specify the directory to clean"
    sys.exit(-1)
  path = sys.argv[1]

  #safety measure
  if "afs" in path:
    print "You are trying to clean a build dir on AFS. Please fix your workflow"
    sys.exit(-1)
 
  print "Free percentage: %s" %free_percentage(path)
  try:
    while free_percentage(path) < required_free_percentage:
       oldest_build = get_oldest_build(path)
       if oldest_build == None:
         print "No old build to clean left."
         print "  Free percentage: %s" %free_percentage(path)
         os._exit(0)
       print "Removing %s" %oldest_build 
       shutil.rmtree( oldest_build, ignore_errors=True )
  except Exception, e:
     print "Cleanup failed. Please investigate"
     print "  Free percentage: %s" %free_percentage(path) 
     print "  Error message: %s" %e
     sys.exit(-1)
    


    
  
