#!/usr/bin/env python

from os import listdir
from os.path import isfile, join
import shutil
import os

# the official area for the RPMS
officialarea = "/afs/cern.ch/sw/lcg/external/rpms/lcg"

# the place where the RPMs have been created
tmp_area = os.environ.get("TMP_RPM_AREA")
if tmp_area in (None, "none") :
    print "Environment variable TMP_RPM_AREA not specified; skipping copy of RPMS to %s" %officialarea
    sys.exit(0)
buildarea = join(os.environ.get("TMP_RPM_AREA"),"rpmbuild/RPMS/noarch/") 

existingrpms = set( f.split("-1.0.0")[0] for f in listdir(officialarea) if isfile(join(officialarea,f)) )
newrpms   = set( f for f in listdir(buildarea) if isfile(join(buildarea,f)) )

# check all rpms and just copy over what doesn't exist yet
# that's the default behaviour
# installing a rebuild is an exceptional task and shouldn't be default 
for item in newrpms:
  if item.split("-1.0.0")[0] not in existingrpms:
    shutil.copy2(join(buildarea,item), officialarea)
    print "Copied %s to %s" %(item, officialarea)
