#!/bin/sh

#
# Check debug symbols in installation area
# Print warning if find it.
# Only 'real' libraries are checked, symlinks are skipped.
# To change this, remove '-type f' in line 16
#

ROOT_PATH=$1
OS=$(uname)
if [ "Darwin" == $OS ];then
  chkcmd="mac_check"
else
  chkcmd="slc_check"
fi

slc_check(){
    readelf --debug-dump "$1" 2> /dev/null
}

mac_check(){
    symbols -onlyDebugMapData "$1" | grep -vE "DATA|TEXT" | tail -n +4 2> /dev/null
}

echo "Checking debug symbols in ${ROOT_PATH}/* ..."
exitcode=0
idx=0
if echo ${ROOT_PATH} | grep -q '\-opt'; then
    echo "The following libraries have debug symbols:"
    for dirs in $(find $ROOT_PATH -maxdepth 4 -type d); do
      for name in $([ -d "$dirs/lib" ] && find "$dirs/lib" -name '*\.so' -o -name '*\.dylib') \
                  $([ -d "$dirs/bin" ] && find "$dirs/bin" ); do
        let "idx = $idx + 1"
        if [ ! -z "$($chkcmd $name)" ]; then
            echo "WARNING: File $name contains debug symbols."
            echo "$name" | grep -q -i MCGenerators && echo "$name" | grep -q -v site-packages && exitcode=1
        fi
      done
    done
elif echo ${ROOT_PATH} | grep -q '\-dbg'; then
    echo "The following libraries don't have debug symbols:"
    for dirs in $(find $ROOT_PATH -maxdepth 4 -type d); do
      for name in $([ -d "$dirs/lib" ] && find $dirs/lib -name '*\.so' -o -name '*\.dylib' | grep '\-dbg') \
                  $([ -d "$dirs/bin" ] && find $dirs/bin | grep '\-dbg'); do
        let "idx = $idx + 1"
        [ -z "$($chkcmd $name)" ] && echo "WARNING: File $name doesn't contain debug symbols."
      done
    done
fi
echo "$idx files checked"
exit $exitcode
