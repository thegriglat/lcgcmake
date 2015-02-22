#!/bin/sh

export LANG=C
listname=".filelist"

# === generate list of files
if [ "generate" = "$1" ]; then
  LCG_home="$2"
  pkg_home="$3"
  while [ ! -z "$4" ];do
    path_map="$4 $path_map"
    shift
  done
  list_file="$pkg_home/$listname"
  tmp_file=$(mktemp -t lcg.XXX)
  tmp_file_list=$(mktemp -t lcg.XXX)
  
  # prepare list of files
  find $pkg_home -type f ! -path '*share/LHAPDF*'  \
                        -o -path '*share/sources*' \
                        -o -path '*datafiles*' -prune | grep -v "$pkg_home/logs"  > $tmp_file_list
  # proceed depends
  for map in $(echo "$path_map"); do
    old_install_path="$(echo $map | cut -d: -f1)"
    old_real_install_path="$(cd $old_install_path; pwd -P)"
    new_directory_name="$(echo $map | cut -d: -f2)"
    echo "$old_real_install_path->$new_directory_name"
    echo "$old_install_path->$new_directory_name"
    # find files
    cat $tmp_file_list | while read name; do
      # check that file is not binary
      if perl -E 'exit((-B $ARGV[0])?1:0);' "$name"; then
        if grep -q -- "$old_install_path" "$name" || grep -q -- "$old_real_install_path" "$name";then
          echo $name | sed -e "s@$pkg_home/@@g"
        fi
      fi
    done
  done >> $tmp_file 
  # prepare $list_file
  echo $LCG_home > $list_file
  cat $tmp_file | grep -- '->' >> $list_file
  cat $tmp_file | sed '/->/d' | sort | uniq >> $list_file
  rm -f $tmp_file
  rm -f $tmp_file_list
  exit 0
fi
# ===

# === Replace install paths in files from filelist
THIS="$0"
PREFIX="$(/bin/sh -c "dirname $THIS")"

while [ ! -d "$INSTALLDIR" ]; do
  [ ! -z "$RPM_INSTALL_PREFIX" ] && INSTALLDIR="$RPM_INSTALL_PREFIX" || read -e -p "Type new install directory : " INSTALLDIR
done

OLDINSTALLDIR="$(head -1 $PREFIX/$listname)"
sed -i -e '1d' $PREFIX/$listname
echo 
echo "Replacing $OLDINSTALLDIR -> $INSTALLDIR"
echo

# prepare package list for replacing

cat $PREFIX/$listname | grep -v -- '->' | while read name; do
  echo "=== Patching $name ... ==="
  old=$(mktemp -t lcg.XXX)
  cp -f "$PREFIX/$name" "$old"
  # patch files
  cat $PREFIX/$listname | grep -- '->' | while read line; do
    olddir="$(echo $line | awk -F'->' '{print $1}')"
    newdir="${INSTALLDIR}/$(echo $line | awk -F'->' '{print $2}')"   
    sed -i -e "s@$olddir@$newdir@g" "$PREFIX/$name"
  done 
  diff -u "$old" "$PREFIX/$name"
  rm -f "$old"
  echo
done

exit 0
