#!/bin/bash

MY_LCG_PLATFORM=`$MCGREPLICA/.scripts/check_platform`
myrivetpath=`/afs/cern.ch/sw/lcg/external/MCGenerators_test/validation/findrivet.sh`

echo 
echo rivet path is: ${myrivetpath}

if [ ! -f ${myrivetpath}/rivetenv.sh ] ; then
  echo
  echo rivet is not found for the platform ${MY_LCG_PLATFORM}
  exit 1
fi

source ${myrivetpath}/rivetenv-genser.sh

rivet-mkhtml -o ${3} -s --mc-errs ${1}:'Title=Reference' ${2}:'LineColor=blue'
