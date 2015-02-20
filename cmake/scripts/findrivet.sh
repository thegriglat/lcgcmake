#!/bin/bash

MY_LCG_PLATFORM=`$MCGREPLICA/.scripts/check_platform`
#echo Your platform is: ${MY_LCG_PLATFORM}

export rivetpath=

for tree in `ls -d /afs/cern.ch/sw/lcg/external/MCGenerators_lcgcmt*` ; do

  if [ ${tree} != "/afs/cern.ch/sw/lcg/external/MCGenerators_lcgcmtpreview" ] ; then

    cd ${tree}/rivet
    export verslist=`ls`
    for version in ${verslist} ; do
      versmajor=`echo ${version} | awk -F . '{print $1}'`
      if [ ${versmajor} = 2 ]; then
        if [ -d ${tree}/rivet/${version} ] ; then
          cd ${tree}/rivet/${version}
          export platflist=`ls`
          for platf in ${platflist} ; do
            if [ ${platf} = ${MY_LCG_PLATFORM} ]; then
              export rivetpath=${tree}/rivet/${version}/${platf}
            fi
          done
        fi
      fi
    done

  fi

done

echo ${rivetpath}
