#!/bin/sh

source $(dirname $0)/config.sh

lockfile=".publish.lock"

if [ -e $lockfile ];then
  read -p  "Repeat publishing ? y|n : " yesno
  case $yesno in 
    y|y* ) ;;
    n|no|* ) echo Exiting ...; exit 0 ;;
  esac
fi

sdir="generators/validation"
echo "Start publishing data ..."
for _pkg in $(ls $sdir); do
  for _ver in $(ls $sdir/$_pkg); do
    publish $_pkg $_ver "$sdir/$_pkg/$_ver"
  done
done

touch $lockfile
