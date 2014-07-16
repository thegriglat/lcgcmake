#!/bin/sh

usage(){
  echo """
  $0 <options>
    -P    Path to yoda files
    -r    Release
    -p    Platform
    -c    Comment
    -d    Path to SQLite3 database (if it is't absolute the file will be saved to <path to yoda file>/ directory)

    The script save all *.yoda files from rivet-based tests to SQLite3 database
"""
}

push2database(){
  pyscript=$(cd $(dirname $0);pwd)/push2database.py
  cd $path
  for name in *.yoda;do
    echo $name | grep -vqE ".*-.*.genser-.*-rivet" && continue # we don't need save reference files
    generator=`echo $name | cut -d- -f 1`
    version=`echo $name   | cut -d- -f 2 | awk -F'.genser' '{print $1}'`
    analysis=`echo $name  | cut -d- -f 3 | awk '{print toupper($0)}'`
    echo -n "Process $generator $version | MC_$analysis ... "
    python $pyscript --platform "$platform" --release "$release" --generator "$generator" --version "$version" --analysis "MC_$analysis" --files "$name" --comment "$comment" $DB
    [ $? -eq 0 ] && echo OK || echo 'Error'
  done 
}

while getopts hP:r:p:c:d: opt; do
  case $opt in
    d) DB=$OPTARG;;
    r) release=$OPTARG;;
    p) platform=$OPTARG;;
    P) path=$OPTARG;;
    c) comment=$OPTARG;;
    h) usage ;exit 0;;
  esac 
done

echo """
Will run with the following parameters:
  Path to yoda files : $path
  Release            : $release
  Platform           : $platform
  Comment            : $comment
  SQLite3 Database   : $DB
"""

push2database

