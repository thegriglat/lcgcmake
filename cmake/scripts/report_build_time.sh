#!/bin/sh

tdir="$1"
tmpfile=$(mktemp)

# get packages names
find $tdir -name '*-start.timestamp' | awk -F'-start.timestamp' '{print $1}' | sed "s@$tdir/@@g" | xargs -n 1 -i{} echo {} >> $tmpfile

cat $tmpfile | while read pkg;do
  secs=$(echo "$(date -r $tdir/$pkg-stop.timestamp -u "+%s") - $(date -r $tdir/$pkg-start.timestamp -u "+%s")" | bc)
  echo -e "$pkg\t\t: $(python -c "hours=$secs/60**2;minutes=$secs/60-hours*60;secs=$secs - hours*60**2 - minutes*60; print \"{0}:{1}:{2}\".format(hours, minutes, secs)")"
done | sort

rm -f $tmpfile
exit 0
