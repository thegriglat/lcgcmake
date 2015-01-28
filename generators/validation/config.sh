#!/bin/sh


getccachevariable(){
  grep $1: CMakeCache.txt 2>/dev/null | cut -d= -f 2-
}

get_AFS_token(){
  while ! klist | grep -q sftnight@CERN.CH; do
    kinit sftnight@CERN.CH
  done
  unlog; aklog
}

git_commit_changes(){
  _cd=$(pwd)
  cd $AFS_TARGET_DIR
  git add .
  git commit -a -m "$tag"
  cd "$_cd"
}

publish(){
  # package version source
  pkg="$1"
  version="$2"
  source="$3"
  tag="${RELEASE}_${pkg}_${version}_${PLATFORM}"
  sitedir="$AFS_TARGET_DIR/${tag}"
  echo get_AFS_token
  get_AFS_token
  echo "Publish files ..." 
  mkdir -p $sitedir
  echo cp -rvf $source/* $sitedir/
  cp -rvf $source/* $sitedir/
  
  [ -e $SITE_CONFIG_FILE ] && sed -i "/${tag}/,/date/d" $SITE_CONFIG_FILE
  echo """${tag}:
  platform: $PLATFORM
  release: $RELEASE
  package: $pkg
  version: \"$version\"
  date: $DATE""" >> $SITE_CONFIG_FILE
  git_commit_changes
}

ncpus=$(grep -c processor /proc/cpuinfo)

AFS_TARGET_DIR=/afs/cern.ch/user/s/sftnight/public/genser.cern.ch/data
SITE_CONFIG_FILE=$AFS_TARGET_DIR/data.yaml
SVN_WEB_ROOT="https://svnweb.cern.ch/trac/lcgsoft/browser/trunk/lcgcmake"
WEB_DATADIR="/data"

BUILD_TARGET="generators/validation"

RELEASE="$(getccachevariable LCG_VERSION)"
PLATFORM="$(getccachevariable LCG_platform)"
# 2015-01-23 09:13:12 as yaml timestamp format
DATE="$(date "+%F %H:%M:%S")"

