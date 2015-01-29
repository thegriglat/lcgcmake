#!/usr/bin/env python

from os import listdir
from os.path import isfile, join
import shutil
import os
from optparse import OptionParser

# extract command line parameters
usage = "usage: %prog localarea remotearea"
parser = OptionParser(usage)
parser.add_option("-g", "--do_generators",
                  action="store_true", dest="do_generators", default=False,
                  help="Whether generators are being synced")
(options, args) = parser.parse_args()    
if len(args) != 2:
    parser.error("incorrect number of arguments.")
else:
    localarea = args[0]   #where RPMS have been build 
    remotearea =  args[1] #where RPMS should be copied to

# the official area for the RPMS
officialarea = "/afs/cern.ch/sw/lcg/external/rpms/lcg"

buildarea = join(localarea,"rpmbuild/RPMS/noarch/") 

existingrpms = set( f.split("-1.0.0")[0] for f in listdir(officialarea) if isfile(join(officialarea,f)) )
newrpms   = set( f for f in listdir(buildarea) if isfile(join(buildarea,f)) )

# check all rpms and just copy over what doesn't exist yet
# that's the default behaviour
# installing a rebuild is an exceptional task and shouldn't be default 
for item in newrpms:
  if item.split("-1.0.0")[0] not in existingrpms:
    shutil.copy2(join(buildarea,item), remotearea)
    print "Copied %s to %s" %(item, remotearea)

# in case we upgrade generators we have to explicitly override LCG_generators_XYZ_ and LCGMeta_XYZ_generators
if options.do_generators:
  for item in newrpms:
    if item.startswith("LCGMeta") or item.startswith("LCG_generators"):
      shutil.copy2(join(buildarea,item), remotearea)
      print "Copied %s to %s" %(item, remotearea)    
