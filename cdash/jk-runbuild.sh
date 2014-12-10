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

# Set up the build variables
export CTEST_SITE=cdash.cern.ch
export WORKDIR=/build/$SLOTNAME
export PDFSETS=ct10
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

THIS=$(dirname $0)
ARCH=$(uname -m)

# clean up the WORKDIR
rm -rf $WORKDIR/*
rm -rf /tmp/the.lock

# setup compiler-------------------------------------------------
if [[ $COMPILER == *gcc* ]] then
  gcc47version=4.7
  gcc48version=4.8
  gcc49version=4.9
  COMPILERversion=${COMPILER}version
  source /afs/cern.ch/sw/lcg/contrib/gcc/${!COMPILERversion}/${ARCH}-${LABEL}/setup.sh
  export FC=gfortran
  export CXX=`which g++`
  export CC=`which gcc`
elif [[ $COMPILER == *clang* ]] then
  clang34version=3.4
  clang35version=3.5
  clang36version=3.6
  COMPILERversion=${COMPILER}version
  clang34gcc=48
  clang35gcc=49
  GCCversion=${COMPILER}gcc
source /afs/cern.ch/sw/lcg/external/llvm/${!COMPILERversion}/${ARCH}-${LABEL}/setup.sh
  export CC=`which clang`
  export CXX=`which clang++`
elif [[ $COMPILER == *native* ]] then

fi
#------------------------------------------------------------------
export BUILD_PREFIX=${WORKDIR}

# print environment -----------------------------------------------
env | sort | sed 's/:/:?     /g' | tr '?' '\n'

# do the build-----------------------------------------------------
ctest -V -S ${THIS}/lcgcmake-build.cmake

