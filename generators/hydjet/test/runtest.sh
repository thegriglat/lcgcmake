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

#svn export svn+ssh://svn.cern.ch/reps/GENSER/validation/trunk/tests/dotest
#svn export svn+ssh://svn.cern.ch/reps/GENSER/validation/trunk/tests/config.mk
#svn export svn+ssh://svn.cern.ch/reps/GENSER/validation/trunk/tests/libtests.mk
svn export svn+ssh://svn.cern.ch/reps/GENSER/validation/trunk/tests/Makefile.hydjet
#svn export svn+ssh://svn.cern.ch/reps/GENSER/validation/trunk/tests/test.dat
#svn export svn+ssh://svn.cern.ch/reps/GENSER/validation/trunk/tests/testi.dat
svn export svn+ssh://svn.cern.ch/reps/GENSER/validation/trunk/tests/hydjet_test0.f
svn export svn+ssh://svn.cern.ch/reps/GENSER/validation/trunk/tests/hydjet_test1.f
svn export svn+ssh://svn.cern.ch/reps/GENSER/validation/trunk/tests/hydjet_test2.f
svn export svn+ssh://svn.cern.ch/reps/GENSER/validation/trunk/tests/hydjet_test3.f
svn export svn+ssh://svn.cern.ch/reps/GENSER/validation/trunk/tests/configure



#~/__cmake/lcgcmake-install/MCGenerators/
./configure --with-hydjetversion=1.8 --mode=lcgcmt64 --run-hydjet=mcgtest
source /afs/cern.ch/sw/lcg/external/MCGenerators_lcgcmt64/libtests/1.02/x86_64-slc5-gcc43-opt/config1.mk
make -f Makefile.hydjet hydjet_test1 PROGNAME=hydjet_test3
source ldlp.sh
./hydjet_test1.exe
