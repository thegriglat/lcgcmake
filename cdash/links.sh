#!/bin/bash

export homedir=`pwd`

for tree in `ls -d /afs/cern.ch/sw/lcg/external/MCGenerators_lcgcmt*` ; do

  cd ${tree}/distribution
  export genlist=`ls`
  cd ${homedir}

  for generator in ${genlist} ; do
    if [ -d ${tree}/distribution/${generator} ] ; then
      cd ${tree}/distribution/${generator}
      export srclist=`ls *-src.tgz`
      cd ${homedir}
      for src in ${srclist} ; do
        if [ ! -s "/afs/cern.ch/sw/lcg/external/MCGenerators/distribution/${generator}/${src}" ] ; then
          echo missing tarball: ${src} ---
          echo making soft link to ${tree}/distribution
          cd /afs/.cern.ch/sw/lcg/external/MCGenerators/distribution
          if [ ! -d ${generator} ] ; then
            echo The directory for the package ${generator} does not exist. Creating it...
            cd ..
#            afs_admin set_acl -r -f distribution _swlcg_ rlidwka system:administrators rlidwka system:anyuser rl lcgapp:spiadm rlidwka lcgapp:genseradm rlidwka lcgapp:genserdev rlidwk -c
            cd distribution
            mkdir ${generator}
            cd ..
#            afs_admin set_acl -r -f distribution _swlcg_ rlidwka system:administrators rlidwka system:anyuser rl lcgapp:spiadm rlidwka -c
            cd /afs/cern.ch/sw/lcg/external/MCGenerators
            afs_admin vos_release distribution
            cd /afs/.cern.ch/sw/lcg/external/MCGenerators/distribution
          fi
#          afs_admin set_acl -r -f ${generator} _swlcg_ rlidwka system:administrators rlidwka system:anyuser rl lcgapp:spiadm rlidwka lcgapp:genseradm rlidwka lcgapp:genserdev rlidwk -c
          cd ${generator}
          ln -fs ${tree}/distribution/${generator}/${src} ${src}
          cd ..
#          afs_admin set_acl -r -f ${generator} _swlcg_ rlidwka system:administrators rlidwka system:anyuser rl lcgapp:spiadm rlidwka -c
          cd /afs/cern.ch/sw/lcg/external/MCGenerators/distribution
          afs_admin vos_release ${generator}
        fi
      done
    fi
  done

done

cd /afs/.cern.ch/sw/lcg/external/MCGenerators
afs_admin set_acl -r -f distribution _swlcg_ rlidwka system:administrators rlidwka system:anyuser rl lcgapp:spiadm rlidwka -c
