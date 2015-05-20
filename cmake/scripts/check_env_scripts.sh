#!/bin/sh

tmp="mktemp"

echo "Only errors will be reported. "
idx=0
find "$1" -maxdepth 5 -type f -name '*-env.sh' -o -name '*env-genser.sh' | while read i; do
  if source $i | grep -qi cannot ;then
    echo "================================="
    echo "ERROR. Cannot properly source $i:"
    echo "================================="
    bash -c "source $i"
  fi
  let "idx = $idx + 1"
done | tee $tmp

echo
echo "$idx files checked."
echo

if grep -q ERROR $tmp ;then
  rm -f $tmp
  exit 1
else
  rm -f $tmp
fi
