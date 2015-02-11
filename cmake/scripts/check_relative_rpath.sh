#!/bin/bash

# 
# Script checks RPATH relative or not
# if yes -- exit with code $REMOVE
# if no  -- exit with code $KEEP
# 11.12.2013
#

KEEP=0
REMOVE=1

function check_rpath(){
    echo $1 | grep -E -q '\.\.\/.*|\$' && return $KEEP || return $REMOVE
}

file=$1

file -L $file | grep -v -q ELF && exit $KEEP

if echo $file | grep -E -q "\.so"; then
    exit $REMOVE
fi

rpath=`readelf -d $file | grep -i rpath | cut -d[ -f2 | cut -d] -f1`
result=0
for path in `echo $rpath | sed 's/:/ /g'`; do
    check_rpath $path
    let "result = $result + $?"
done
[ $result -gt 0 ] && result=$REMOVE

exit $result
