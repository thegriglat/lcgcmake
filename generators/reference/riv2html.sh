#!/bin/bash

echo arguments:
echo $1 - path to rivet
echo $2 - generator name
echo $3 - process name
echo $4 - LCG version
echo $5 - platform
echo end arguments

RESULTSTORE=/afs/cern.ch/sw/lcg/external/MCGenerators_test/validation

mkdir -p ${RESULTSTORE}/yoda
cp -f ${2}_riv2_${3}.yoda ${RESULTSTORE}/yoda/${2}_${3}_ref.yoda
cp -f ${2}_riv2_${3}_i.yoda ${RESULTSTORE}/yoda/${2}_${3}_${4}_${5}.yoda

echo
echo yoda file with results is produced and put together with the reference on AFS
echo
echo to get html page with comparison in the directory ./myhtml run the following:
echo
echo ${RESULTSTORE}/runmkhtml.sh ${RESULTSTORE}/yoda/${2}_${3}_ref.yoda ${RESULTSTORE}/yoda/${2}_${3}_${4}_${5}.yoda myhtml
echo
echo after this you can see the page by typing:
echo
echo firefox myhtml/index.html
echo

#source $1/rivetenv.sh
#rivet-mkhtml -o ${2}html -s --mc-errs ${2}_riv2.yoda:'Title=Reference' ${2}_riv2_i.yoda:'LineColor=blue'
