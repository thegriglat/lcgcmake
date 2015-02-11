#!/bin/bash

#Accepting following parameters:
#  $1: buildtype (Debug,Release)  
#  $2: compiler version
#  $3: slotname
BUILDTYPE="$1"
COMPILER_VER="$2"
SLOTNAME="$3"

# A few default parameters of the build
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

#set up the build variables                                                                                      
export CTEST_SITE=cdash.cern.ch
export WORKDIR=/build/$SLOTNAME
export PDFSETS=minimal
export VERSION=trunk
export TARGET=all

export CLEAN_INSTALLDIR="false"
export INSTALLDIR=
export LCG_IGNORE=
export TEST_LABELS=
export LCG_TARBALL_INSTALL="false"
export SLOTNAME=$SLOTNAME
export TEST_LABELS="Nightly|PhysicsCheck"

export BUILDTYPE
export MODE=$SLOTNAME
export LCG_VERSION=$SLOTNAME

# clean up the WORKDIR 
rm -rf $WORKDIR/*
rm -rf /tmp/the.lock

# 
echo "Running build of lcgcmake version $SLOTNAME on ${COMPILER_VER}-${BUILDTYPE}."

# fetch the building scripts; multiple times because of CERN svn instability
svn co http://svn.cern.ch/guest/lcgsoft/trunk/lcgcmake/cdash $WORKDIR/lcg-scripts; 
svn co http://svn.cern.ch/guest/lcgsoft/trunk/lcgcmake/cdash $WORKDIR/lcg-scripts;
svn co http://svn.cern.ch/guest/lcgsoft/trunk/lcgcmake/cdash $WORKDIR/lcg-scripts;
# $WORKDIR/lcg-scripts/clean_disk.py $WORKDIR/lcg-builds

if [ ! -f "$WORKDIR/lcg-scripts/ec-slc6-$COMPILER_VER" ]; then
    echo "Invalid compiler version, there is no configuration script for \'$COMPILER_VER\'"
    exit 1
fi

printenv

if "$WORKDIR/lcg-scripts/ec-slc6-$COMPILER_VER" ; then
    :
else
    echo "CTEST driven build failed with exit status $?"
fi

echo "Build finished: `date`"
