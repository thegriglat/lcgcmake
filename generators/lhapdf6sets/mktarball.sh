#!/bin/bash -e

instdir="$1"
version="$2"

echo "Preparing PDF sets tarball ..."

cd $instdir/../../..
mkdir -p distribution/lhapdf6sets

data=lhapdf6sets/$version/share
marker=$data/LHAPDF/.complete
tarball=distribution/lhapdf6sets/lhapdf6sets-$version-src.tgz

echo "pwd = $(pwd)"
echo "data = $(pwd)/$data"
echo "marker = $(pwd)/$marker"
echo "tarball = $(pwd)/$tarball"

# check PDF sets installation
if [ ! -e $marker ] ; then
  echo "INFO: PDF sets installation is in progress (marker is missing), skip tarball creation"
  exit 0
fi

# check tarball
if [ -e $tarball ] ; then
  if [ $tarball -nt $marker ] ; then
    # tarball exists already and newer than marker
    echo "PDF sets tarball is up to date already"
    exit 0
  fi
fi

# tarball does not exists or obsolete, create new one:
tar -czf $tarball $data

echo "PDF sets tarball prepared successfully"
