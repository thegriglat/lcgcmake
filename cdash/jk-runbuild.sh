#!/bin/bash -x

# This script assumes a full set on environment variables setup by executing jk-setup.sh
#  CTEST_SITE, WORKDIR, PDFSETS, BUILDTYPE, etc.
#  together with the compiler and additional tools such as CMake itself

THIS=$(dirname $0)

PLATFORM=`$THIS/getPlatform.py`

# clean up the WORKDIR ------------------------------------------
rm -rf $WORKDIR/$PLATFORM-build
rm -rf $WORKDIR/$PLATFORM-install
rm -rf /tmp/the.lock

# print environment -----------------------------------------------
env | sort | sed 's/:/:?     /g' | tr '?' '\n'

# do the build-----------------------------------------------------
ctest -V -S $THIS/lcgcmake-build.cmake

