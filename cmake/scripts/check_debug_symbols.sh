#!/bin/sh

#
# Check debug symbols in installation area
# Print warning if find it.
# Only 'real' libraries are checked, symlinks are skipped.
# To change this, remove '-type f' in line 16
#
# 12.12.2013

ROOT_PATH=$1
echo "ROOT_PATH=$ROOT_PATH"
exitcode=0
find $ROOT_PATH -type f -name *.so | while read name; do
    debug=`readelf --debug-dump $name 2> /dev/null`
    if [ "x$debug" != "x" ];then
        echo "WARNING: File $name contains debug symbols."
    fi
done
exit $exitcode
