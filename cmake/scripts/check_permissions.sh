#!/bin/sh

permfile="permissions.log"
if [ -e $permfile ]; then
    rm -f $permfile
fi
find "$1" ! -perm -o=r 2>/dev/null > $permfile
SIZE=$(cat $permfile | wc -l) 
if [ $SIZE  -gt 0 ]; then
  echo "Wrong permissions:"
  cat $permfile | xargs -n 1 ls -ld
  exit 1
else
  echo "All permissions are OK."
fi
exit 0
