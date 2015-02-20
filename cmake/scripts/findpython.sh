#!/bin/bash

#deprecated script

MY_LCG_PLATFORM=`$MCGREPLICA/.scripts/check_platform`
#echo Your platform is: ${MY_LCG_PLATFORM}

export pythonpath=/afs/cern.ch/sw/lcg/external/Python/2.7.3/${MY_LCG_PLATFORM}/bin

echo ${pythonpath}
