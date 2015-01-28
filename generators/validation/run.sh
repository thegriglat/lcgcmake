#!/bin/sh

source $(dirname $0)/config.sh

name="$1"
ppname=$( echo $1 | sed 's@+@p@g')
version="$2"
tag="${RELEASE}_${name}_${version}_${PLATFORM}"

[ -e "$(dirname $0)/$name.sh" ] && source "$(dirname $0)/$name.sh"

target="$BUILD_TARGET/$name/$version"
yamlfile="$BUILD_TARGET/$name/$version/content.yaml"

for t in $extra_tests; do
  [ ! -e "tests/$t.log" ] && ctest -j $ncpus -R $t
done

ctest -j $ncpus -R $ppname-$version..*rivet

rm -rf $target
mkdir -p $target

echo "package: $name
version: \"$version\"
files:""" > $yamlfile

for f in generators/$ppname-$version*.yoda \
         generators/$ppname-$version*.root 
         #generators/$ppname-$version*.dat;
         do
  # rename
  newname=$(echo $f | sed "s@generators/$ppname-$version.@@g")
  cp -vf $f "$target/$newname"
  echo "  - \"$newname\"" >> $yamlfile
done

echo "configs:" >> $yamlfile
for f in $svn_config_files; do
  echo " - $SVN_WEB_ROOT/$f" >> $yamlfile
done

for f in $build_config_files; do
  cp -v $f "$target/"
  echo " - $WEB_DATADIR/$tag/$(basename "$f")" >> $yamlfile
done


