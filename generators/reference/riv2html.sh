#!/bin/bash

echo arguments:
echo $1 - path to rivet
echo $2 - generator name
echo $3 - generator version
echo $4 - process name
echo $5 - LCG version
echo $6 - platform
echo end arguments

RESULTSTORE=/afs/cern.ch/sw/lcg/external/MCGenerators_test/validation

if [[ -w ${RESULTSTORE} ]] ; then
  mkdir -p ${RESULTSTORE}/yoda
  cp -f ${2}.genser-${4}-rivet.yoda ${RESULTSTORE}/yoda/${2}_${4}_ref.yoda
  cp -f ${2}-${3}.genser-${4}-rivet.yoda ${RESULTSTORE}/yoda/${2}_${3}_${4}_${5}_${6}.yoda
  echo
  echo yoda file with results is produced and put together with the reference on AFS
  echo
  echo to get html page with comparison in the directory ./myhtml run the following:
  echo
  echo ${RESULTSTORE}/runmkhtml.sh ${RESULTSTORE}/yoda/${2}_${4}_ref.yoda ${RESULTSTORE}/yoda/${2}_${3}_${4}_${5}_${6}.yoda myhtml
  echo
  echo after this you can see the page by typing:
  echo
  echo firefox myhtml/index.html
  echo
else
  echo
  echo AFS store is not available or not writable
  echo to get html page with comparison in the directory ./myhtml do the following:
  echo
  echo login to ${HOSTNAME} and use scp or sftp for copying below
  echo
  mylocation=$(pwd)
  echo copy ${mylocation}/${2}.genser-${4}-rivet.yoda  to  ${RESULTSTORE}/yoda/${2}_${4}_ref.yoda
  echo copy ${mylocation}/${2}-${3}.genser-${4}-rivet.yoda  to  ${RESULTSTORE}/yoda/${2}_${3}_${4}_${5}_${6}.yoda
  echo
  echo then on the node with AFS do the following:
  echo
  echo ${RESULTSTORE}/runmkhtml.sh ${RESULTSTORE}/yoda/${2}_${4}_ref.yoda ${RESULTSTORE}/yoda/${2}_${3}_${4}_${5}_${6}.yoda myhtml
  echo
  echo after this you can see the page by typing:
  echo
  echo firefox myhtml/index.html
  echo
fi

#source $1/rivetenv.sh
#rivet-mkhtml -o ${2}html -s --mc-errs ${2}_riv2_${4}.yoda:'Title=Reference' ${2}_riv2_${4}_i.yoda:'LineColor=blue'
