#!/bin/sh

tdir="$1"
tmpfile=$(mktemp -t XXXXX)

# get packages names
find $tdir -name '*-start.timestamp' | awk -F'-start.timestamp' '{print $1}' | sed "s@$tdir/@@g" | xargs -n 1 -i{} echo {} >> $tmpfile

cat $tmpfile | while read pkg;do
  if [ -f "$tdir/$pkg-stop.timestamp" -a -f "$tdir/$pkg-start.timestamp" ];then
    secs=$(echo "$(date -r $tdir/$pkg-stop.timestamp -u "+%s") - $(date -r $tdir/$pkg-start.timestamp -u "+%s")" | bc)
    python -c "hours=$secs/60**2;minutes=$secs/60-hours*60;secs=$secs - hours*60**2 - minutes*60; print \"{0:30s} : {1:6d} second(s) ({2:2d} hour(s) {3:2d} minute(s) {4:2d} second(s))\".format(\"$pkg\", $secs, hours, minutes, secs)"
  fi
done | sort -n -k 3 -r

rm -f $tmpfile
exit 0
