#!/bin/bash

# Accepting following parameters:
#  $1: buildtype (Debug,Release)
#  $2: compiler version
#  $3: slotname

THIS=$(dirname ${BASH_SOURCE[0]})
ARCH=$(uname -m)

if [ $# -ge 3 ]; then
  BUILDTYPE=$1; shift
  COMPILER=$1; shift
  SLOTNAME=$1; shift
else
  echo "$0: expecting 3 arguments: [buildtype] [compiler] [slotname]"
  return
fi

# A few default parameters of the build--------------------------------------------
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Set up the build variables-------------------------------------------------------
export CTEST_SITE=cdash.cern.ch
export WORKDIR=/build/$SLOTNAME
export INSTALLDIR=
export PDFSETS=minimal
export CLEAN_INSTALLDIR="false"
export LCG_TARBALL_INSTALL="false"
export SLOTNAME
export BUILDTYPE
export COMPILER
export PLATFORM=`$THIS/getPlatform.py`

if [[ $SLOTNAME == dev* ]]; then export MODE=$SLOTNAME
elif [ -z $SLOTNAME ];      then export MODE=Experimental
else                             export MODE=Release; fi

if [ -z $VERSION ];     then export VERSION=trunk; fi
if [ -z $TARGET ];      then export TARGET=all; fi
if [ -z $TEST_LABELS ]; then export TEST_LABELS="Nightly|PhysicsCheck"; fi
if [ -z $LCG_VERSION ]; then export LCG_VERSION=$SLOTNAME; fi

# setup cmake for slc6 nodes ------------------------------------------------------
if [[ $PLATFORM == *slc6* ]]; then
  export PATH=/afs/cern.ch/sw/lcg/contrib/CMake/2.8.12.2/Linux-i386/bin:${PATH}
  LABEL=slc6
fi

# setup compiler-------------------------------------------------------------------
if [[ $COMPILER == *gcc* ]]; then
  gcc47version=4.7
  gcc48version=4.8
  gcc49version=4.9
  COMPILERversion=${COMPILER}version
  . /afs/cern.ch/sw/lcg/contrib/gcc/${!COMPILERversion}/${ARCH}-${LABEL}/setup.sh
  export FC=gfortran
  export CXX=`which g++`
  export CC=`which gcc`
elif [[ $COMPILER == *clang* ]]; then
  clang34version=3.4
  clang35version=3.5
  clang36version=3.6
  COMPILERversion=${COMPILER}version
  clang34gcc=48
  clang35gcc=49
  GCCversion=${COMPILER}gcc
  . /afs/cern.ch/sw/lcg/external/llvm/${!COMPILERversion}/${ARCH}-${LABEL}/setup.sh
  export CC=`which clang`
  export CXX=`which clang++`
elif [[ $COMPILER == *native* ]]; then
  echo nothing
fi