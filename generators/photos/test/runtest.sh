#!/bin/bash -e

# ARG1: CURRENT DIRECTORY
# ARG1: MCGTESTDIR
# ARG2: CONFIGURE_ARG

if [ "$1" != "" ]; then
 cd $1
fi
export MCGTESTDIR=$2
source /afs/.cern.ch/sw/lcg/external/MCGenerators/.work/GBUILD/noarch/TOOLS/genser.rc
./configure --with-photosversion=$3 --run-photos=mcgtest
source config.mk
make -f Makefile.photos photos_test1
source ldlp.sh
./photos_test1.exe
