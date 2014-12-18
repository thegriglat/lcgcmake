#!/bin/bash
# The following variables are expected:
#  SLOT:      Nightly slot name
#  LABEL:     Worker node label (e.g. slc6)
#  COMPILER:  Compiler and version
#  BUILDTYPE: Build type (e.g. Release)

isdone=$1

arch=`uname -p`

if [[ $LABEL == *slc6* ]]; then
  LABEL=slc6
fi

if [ $BUILDTYPE == Release ]; then
  bt=opt
elif [ $BUILDTYPE == Debug ]; then
  bt=dbg
else
  bt=unk
fi

platform=$arch-$LABEL-$COMPILER-$bt
today=$(date +%a)
nightdir=/afs/cern.ch/sw/lcg/app/nightlies
donefile=$nightdir/$SLOT/$today/isDone-$platform

if [ $isdone == 1 ]; then
  touch $donefile
  echo "Created file $donefile"
else
  rm -f $donefile
  echo "Removed file $donefile"
fi
