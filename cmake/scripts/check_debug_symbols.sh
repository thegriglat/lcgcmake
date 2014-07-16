#!/bin/sh

#
# Check debug symbols in installation area
# Print warning if find it.
# Only 'real' libraries are checked, symlinks are skipped.
# To change this, remove '-type f' in line 16
#
# 12.12.2013

ROOT_PATH=$1
OS=$(uname)
[ "Darwin" == $OS ] && filepattern="-name *.dylib" || filepattern="-name *.so"

slc_check(){
    readelf --debug-dump "$1" 2> /dev/null
}

mac_check(){
    symbols -onlyDebugMapData "$1" | grep -vE "DATA|TEXT" | tail -n +4
}

check(){
    if [ "Darwin" == $OS ];then
        mac_check "$1"
    elif [ "Linux" == $OS ]; then
        slc_check "$1"
    else
        echo "Cannot determine Operating System: $OS."
        exit 1
    fi
}

echo "Checking debug symbols in ${ROOT_PATH}/* ..."
exitcode=0
if echo ${ROOT_PATH} | grep -q '\-opt'; then
    echo "The following libraries have debug symbols:"
    for dirs in $(find $ROOT_PATH -maxdepth 4 -type d); do
      for name in $([ -d "$dirs/lib" ] && find $dirs/lib -type f $filepattern) $([ -d "$dirs/bin" ] && find $dirs/bin -type f $filepattern); do
        debug=$(check "$name")
        if [ "x$debug" != "x" ];then
            echo "WARNING: File $name contains debug symbols."
            echo "$name" | grep -q -i MCGenerators && echo "$name" | grep -q -v site-packages && exitcode=1
        fi
      done
    done
elif echo ${ROOT_PATH} | grep -q '\-dbg'; then
    echo "The following libraries don't have debug symbols:"
    for dirs in $(find $ROOT_PATH -maxdepth 4 -type d); do
      for name in $([ -d "$dirs/lib" ] && find $dirs/lib -type f $filepattern | grep '\-dbg') $([ -d "$dirs/bin" ] && find $dirs/bin -type f $filepattern | grep '\-dbg'); do
        debug=$(check "$name")
        if [ "x$debug" = "x" ];then
            echo "WARNING: File $name doesn't contain debug symbols."
        fi
      done
    done
fi
exit $exitcode
