#!/bin/sh

#
# Check debug symbols in installation area
# Print warning if find it.
# Only 'real' libraries are checked, symlinks are skipped.
# To change this, remove '-type f' in line 16
#
# 12.12.2013

ROOT_PATH=$1
echo "Checking debug symbols in ${ROOT_PATH}/* ..."
exitcode=0
if echo ${ROOT_PATH} | grep -q '\-opt'; then
    echo "The following libraries have debug symbols:"
    find $ROOT_PATH -type f -name *.so | while read name; do
        debug=`readelf --debug-dump $name 2> /dev/null`
        if [ "x$debug" != "x" ];then
            echo "WARNING: File $name contains debug symbols."
            echo $name | grep -q -i MCGenerators && exitcode=1
        fi
    done
elif echo ${ROOT_PATH} | grep -q '\-dbg'; then
    echo "The following libraries don't have debug symbols:"
    find $ROOT_PATH -type f -name *.so  | grep '-dbg' | while read name; do
        debug=`readelf --debug-dump $name 2> /dev/null`
        if [ "x$debug" = "x" ];then
            echo "WARNING: File $name doesn't contain debug symbols."
        fi
    done
fi
exit $exitcode
