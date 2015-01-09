#!/bin/bash
# The following variables are expected:
#  SLOTNAME:  Nightly slot name
#  LABEL:     Worker node label (e.g. slc6)
#  COMPILER:  Compiler and version
#  BUILDTYPE: Build type (e.g. Release)

isdone=$1

arch=`uname -p`
this=$(dirname $0)

platform=`$this/getPlatform.py`

today=$(date +%a)
nightdir=/afs/cern.ch/sw/lcg/app/nightlies
donefile=$nightdir/$SLOTNAME/$today/isDone-$platform

if [ $isdone == 1 ]; then
  touch $donefile
  echo "Created file $donefile"
else
  rm -f $donefile
  echo "Removed file $donefile"
fi
