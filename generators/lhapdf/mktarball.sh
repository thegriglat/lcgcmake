#!/bin/bash -e

instdir="$1"
version="$2"

echo "Preparing PDF sets tarball ..."

cd $instdir/../../..
mkdir -p distribution/lhapdfsets

data=lhapdfsets/$version/share
marker=$data/lhapdf/PDFsets/.complete
tarball=distribution/lhapdfsets/lhapdfsets-$version-src.tgz

echo "pwd = $(pwd)"
echo "data = $(pwd)/$data"
echo "marker = $(pwd)/$marker"
echo "tarball = $(pwd)/$tarball"

# check PDF sets installation
if [ ! -e $marker ] ; then
  echo "ERROR: PDF sets installation is not complete (marker is missing)"
  exit 1
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
