#!/usr/bin/env python

# This script looks into existing RPMS and gives the lowest not used RPM revision

from os import listdir
from os.path import isfile, join
import shutil
import os
from optparse import OptionParser

# extract command line parameters
usage = "usage: %prog lcgversion platform"
parser = OptionParser(usage)
(options, args) = parser.parse_args()    
if len(args) != 2:
    parser.error("incorrect number of arguments.")
else:
    lcgversion =  args[0] # lcgversion being built
    platform   =  args[1] # platform being built for

# the official area for the RPMS
officialarea = "/afs/cern.ch/sw/lcg/external/rpms/lcg"

# get the LCGMeta rpm revisions and print the highest one
existingrpms = [ f.split("-")[2].split(".")[0] for f in listdir(officialarea) if isfile(join(officialarea,f)) and f.startswith("LCGMeta_%s_generators"%lcgversion) and platform.replace("-","_") in f]
existingrpms.sort()
print int(existingrpms[-1])+1
