#!/bin/sh

tmp="$(mktemp)"
tmp1="$(mktemp)"

echo "Only errors will be reported. "
find "$1" -maxdepth 5 -type f -name '*-env.sh' -o -name '*env-genser.sh' | while read i; do
  if source $i | grep -qi cannot ;then
    echo "================================="
    echo "ERROR. Cannot properly source $i:"
    echo "================================="
    bash -c "source $i"
  fi
  echo >> $tmp1
done | tee $tmp

echo
echo "$(cat $tmp1 | wc -l) files checked."
echo

rm -f $tmp1

if grep -q ERROR $tmp ;then
  rm -f $tmp
  exit 1
else
  rm -f $tmp
fi
