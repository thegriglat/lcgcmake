#!/bin/bash
# ARG1: CURRENT DIRECTORY

if [ "$1" != "" ]; then
 cd $1
fi


source /afs/.cern.ch/sw/lcg/external/MCGenerators/.work/GBUILD/noarch/TOOLS/genser.rc
export MCGTESTDIR=$2
./configure --with-hydjetversion=$3 --run-hydjet=mcgtest
source config.mk
make -f Makefile.hydjet hydjet_test1 PROGNAME=hydjet_test3
source ldlp.sh
./hydjet_test1.exe