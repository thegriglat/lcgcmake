#!/bin/sh

#
# Check debug symbols in installation area
# Print warning if find it.
# Only 'real' libraries are checked, symlinks are skipped.
# To change this, remove '-type f' in line 16
#

ROOT_PATH=$1
build_type=$2
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

if [ "opt" = "$build_type" ]; then
    echo "The following libraries have debug symbols:"
    for dirs in $(find $ROOT_PATH -maxdepth 4 -type d); do
      echo $dirs | grep -q -v $build_type && continue 
      for name in $([ -d "$dirs/lib" ] && find "$dirs/lib" -name '*\.so' -o -name '*\.dylib') \
                  $([ -d "$dirs/bin" ] && find "$dirs/bin" ); do
        if file $name 2>/dev/null | grep -q ELF && [ ! -z "$($chkcmd $name)" ]; then
            if echo "$name" | grep -q -i MCGenerators && echo "$name" | grep -q -v site-packages; then
              exitcode=1
              status="CRITICAL"
            else
              status="WARNING"
            fi
            echo "$status: File $name contains debug symbols."
        fi
      done
    done
elif [ "dbg" = "$build_type" ]; then
    echo "The following libraries don't have debug symbols:"
    for dirs in $(find $ROOT_PATH -maxdepth 4 -type d); do
      echo $dirs | grep -q -v $build_type && continue 
      for name in $([ -d "$dirs/lib" ] && find $dirs/lib -name '*\.so' -o -name '*\.dylib') \
                  $([ -d "$dirs/bin" ] && find $dirs/bin ); do
        if file $name 2>/dev/null | grep -q ELF && [ -z "$($chkcmd $name)" ] ; then
          if echo "$name" | grep -q -i MCGenerators && echo "$name" | grep -q -v site-packages; then
            exitcode=1
            status="CRITICAL"
          else
            status="WARNING"
          fi
          echo "$status: File $name doesn't contain debug symbols."
        fi
      done
    done
fi
echo "Exiting with code $exitcode ..."
exit $exitcode
