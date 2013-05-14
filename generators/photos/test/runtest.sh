#!/bin/bash -e

echo "===> [test] arguments = $*"
echo ""

# ARG1: CURRENT DIRECTORY
# ARG1: MCGTESTDIR
# ARG2: CONFIGURE_ARG
# ARG3: PATH TO config1.mk

if [ "$1" != "" ]; then
 cd $1
fi
export MCGTESTDIR=$2

svn export svn+ssh://svn.cern.ch/reps/GENSER/validation/trunk/tests/Makefile.photos
svn export svn+ssh://svn.cern.ch/reps/GENSER/validation/trunk/tests/photos_test1.F
svn export svn+ssh://svn.cern.ch/reps/GENSER/validation/trunk/tests/configure


#~/__cmake/lcgcmake-install/MCGenerators/
./configure --with-photosversion=215.4 --mode=lcgcmt64 --run-photos=mcgtest
source /afs/cern.ch/sw/lcg/external/MCGenerators_lcgcmt64/libtests/1.02/x86_64-slc5-gcc43-opt/config1.mk
make -f Makefile.photos photos_test1
source ldlp.sh
./photos_test1.exe
