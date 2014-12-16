#!/bin/sh

export LANG=C
listname=".filelist"

# === generate list of files
if [ "generate" = "$1" ]; then
  pkg_home="$2"
  list_file="$pkg_home/$listname"
  # save OLDINSTALLDIR
  echo $pkg_home > $list_file
  find $pkg_home -type f ! -path '*share/LHAPDF*' -o -path '*share/sources*' | grep -v "$pkg_home/logs" | while read name; do
    # check that file is not binary
    if perl -E 'exit((-B $ARGV[0])?1:0);' "$name"; then
      grep -q -- "$pkg_home" "$name" && echo $name | sed -e "s@$pkg_home/@@g" >> $list_file
    fi
  done
  exit 0
fi
# ===

# === Replace install paths in files from filelist
THIS="$0"
PREFIX="$(/bin/sh -c "dirname $THIS")"

INSTALLDIR="$(cd `dirname $THIS`;pwd -P)"
OLDINSTALLDIR="$(head -1 $PREFIX/$listname)"
sed -i -e '1d' $PREFIX/$listname
echo 
echo "Replacing $OLDINSTALLDIR -> $INSTALLDIR"
echo

cat $PREFIX/$listname | while read name; do
  echo "=== Patching $name ... ==="
  old=$(mktemp)
  cp -f "$INSTALLDIR/$name" "$old"
  sed -i -e "s@$OLDINSTALLDIR@$INSTALLDIR@g" "$INSTALLDIR/$name"
  diff -u "$old" "$INSTALLDIR/$name"
  rm -f "$old"
done
exit 0
