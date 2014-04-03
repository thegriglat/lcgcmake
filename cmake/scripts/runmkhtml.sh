#!/bin/bash

mypythonpath=`/afs/cern.ch/sw/lcg/external/MCGenerators_test/validation/findpython.sh`

myrivetpath=`/afs/cern.ch/sw/lcg/external/MCGenerators_test/validation/findrivet.sh`

export PATH=/afs/cern.ch/sw/lcg/external/Python/2.7.3/x86_64-slc5-gcc47-opt/bin:${PATH}

source ${myrivetpath}/rivetenv.sh

rivet-mkhtml -o ${3} -s --mc-errs ${1}:'Title=Reference' ${2}:'LineColor=blue'
