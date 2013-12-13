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
total=0
debfile=0
find $ROOT_PATH -type f -name *.so | while read name; do
    debug=`readelf --debug-dump $name 2> /dev/null`
    if [ "x$debug" != "x" ];then
        echo "WARNING: File $name consists debug symbols."
        let "debfile = $debfile + 1"
    fi
    let "total = $total + 1"
done
echo "Total *.so files         : $total"
echo "Files with debug symbols : $debfile"
exit $exitcode
