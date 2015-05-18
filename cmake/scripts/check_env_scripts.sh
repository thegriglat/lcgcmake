#!/bin/sh

tmp="mktemp"

find "$1" -type f -name '*-env.sh' -o -name '-*env-genser.sh' | while read i; do
  echo -n "Checking $i ... "
  if source $i | grep -qi cannot ;then
    echo "FAILED. Cannot properly source $i:"
    bash -c "source $i"
    
  else
    echo "OK"
  fi
done |& tee $tmp
if grep -q FAILED $tmp ;then
  rm -f $tmp
  exit 1
else
  rm -f $tmp
fi
