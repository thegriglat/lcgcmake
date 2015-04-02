#!/bin/bash
# test
AFS_base_dir="/afs/cern.ch/sw/lcg/external"
CVMFS_base_dir="/cvmfs/sft.cern.ch/lcg/external"

# limits
FILE_LIMIT=250000      
SIZE_LIMIT=10737418240 # in bytes (10G)
# ===

function B2M(){
  # convert bytes to Mbytes
  echo "$(echo "$1/1024/1024" | bc)M"
}

function copy_package() {
  source_dir=$1
  target_dir=$2
  
  local base_dir=$(dirname $target_dir)
  
  mkdir -p $base_dir || return 1
  output="$(mktemp)"
  rsync --stats -n -a -u -v --delete --exclude 'sources' --exclude '.svn/' --exclude 'CVS/' --exclude '.work/' --exclude '.scripts/' --exclude 'distribution/' --exclude 'lib/**.pyc' $source_dir $base_dir > "$output"
  n_changes=$(cat $output | awk '/Number of files transferred:/{print $5}')
  s_changes=$(cat $output | awk '/Total transferred file size:/{print $5}')
  cat $output
  if test $n_changes -gt $FILE_LIMIT -o $s_changes -gt $SIZE_LIMIT ; then 
    echo 'ERROR: too many changed files or too big size of transaction:'
    echo "  Files: $n_changes"
    echo "    limit : $FILE_LIMIT"
    echo "  Size : $s_changes bytes ($(B2M $s_changes))"
    echo "    limit : $SIZE_LIMIT bytes ($(B2M $SIZE_LIMIT))"
    echo "Help : Please split your transaction into a few more small ones. !!!"
    exit 1
  fi 

  mkdir -p $base_dir || return 1

  echo "You are going to sync:"
  echo "  Files: $n_changes files"
  echo "  Size : $s_changes bytes (it is about $(B2M $s_changes))"
  echo
  echo "(STEP 2) copying package(s)"
  rm -f "$output"

while true; do
    read -p "Do you wish to proceed with syncronization? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "Exiting......"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

  echo " procceeding with syncronization...... " 

 rsync --stats -a -u -v --exclude 'sources' --exclude '.svn/' --exclude 'CVS/' --exclude '.work/' --exclude '.scripts/' --exclude 'distribution/' --exclude 'lib/**.pyc' $source_dir $base_dir || return 1
}

function relocate_package_rpath() {
  target_dir=$1
  local patchelf="/afs/cern.ch/sw/lcg/app/spi/tools/dev/patchelf"
  
  echo "  relocate package rpath"
  
  find $target_dir -wholename "*/bin/*" -o -name "*.so*" | while read file ; do
    if test -L $file ; then
      #echo "  file is symlink - skip"
      continue
    fi
    
    rpath=$($patchelf --print-rpath $file 2>/dev/null)
    
    if [[ "$?" != "0" ]] ; then
      #echo "  not an ELF executable file - skip"
      continue
    fi
    
    if [[ "$rpath" = "" ]] ;then
      #echo "  no rpath - skip"
      continue
    fi
    
    new_rpath=$(echo $rpath | \
                sed -e "s,/afs/.cern.ch,/afs/cern.ch,g" \
                    -e "s,sw/lcg/contrib/gcc,sw/lcg/external/gcc,g" \
                    -e "s,$AFS_base_dir,$CVMFS_base_dir,g")
    
    if [[ "$rpath" != "$new_rpath" ]] ; then
      echo "  $file"
      echo "    $rpath -> $new_rpath"
      
      $patchelf --set-rpath "$new_rpath" "$file"
      
      # for debugging purposes:
      #check_rpath=$($patchelf --print-rpath $file)
      #if check_rpath != rpath: print "Seems it didn't work for %s" %filename
    fi
  done
  
  echo ""
}

# fix paths in *-config and *.la files:
function fix_package_files() {
  target_dir=$1
  
  echo "  fix package files"
  
  {
    find $target_dir -name "*-config" -o -name "*.la"
    find $target_dir -type f -wholename "*share/Herwig++*"
    find $target_dir -type f -wholename "*bin/rivet*"
    find $target_dir -type f -name "rivetenv.*sh"
    find $target_dir -type f -name "ThePEGDefaults*.rpo"
    find $target_dir -type f -name "*share/*.in"
    find $target_dir -type f -name "agileenv.*sh"
  } | \
  while read file ; do
    if ! grep -q afs $file ; then
      #echo "  nothing to fix - skip"
      continue
    fi
    
    echo "  $file"
    
    sed -e "s,/afs/.cern.ch,/afs/cern.ch,g" \
        -e "s,sw/lcg/contrib/gcc,sw/lcg/external/gcc,g" \
        -e "s,$AFS_base_dir,$CVMFS_base_dir,g" \
        -i $file
  done
  
  echo ""
}

# remove *.pyc files
function drop_pyc_files() {
  target_dir=$1
  
  echo "  drop pyc files"
  
  find $target_dir -type f -wholename "*/lib/*" -name "*.pyc" | while read file ; do
    echo "  $file"
    
    rm -f $file
  done
  
  echo ""
}

# === main ===

if (( "$#" != "1" )) ; then
  echo "Usage:"
  echo "  $0 {source base dir} {target base dir} {subpath}"
  exit 1
fi

path=$1

if grep '^[a-zA-Z0-9\-\_\/\.\-\+]*$' <<< $path;
 then
  if grep '\.\./' <<< $path;
   then echo bad subpath; exit 1;   
  fi;
 else echo bad subpath; exit 1;
fi


if [ "${path: -1}" = "/" ] ; then
  path="${path%?}"
fi

# setup environment (32 bits) for patchelf tool
source /afs/cern.ch/sw/lcg/contrib/gcc/4.3.5/i686-slc5-gcc43-opt/setup.sh

    source_dir="$AFS_base_dir/$path"
    target_dir="$CVMFS_base_dir/$path"
    
    echo "$source_dir -> $target_dir"
    
    # copy package:
    copy_package $source_dir $target_dir || exit 1
    
    # fix rpath:
    relocate_package_rpath $target_dir
    
    # fix paths in *-config files:
    fix_package_files $target_dir
    
    # remove *.pyc files:
    drop_pyc_files $target_dir

echo "Done!"
