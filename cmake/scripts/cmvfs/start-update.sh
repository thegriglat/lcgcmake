#!/usr/bin/bash
dryrun=
publish=
subpath=
OPTIND=1
verbose=0
while getopts ":hws:" opt; do
	case "$opt" in 
	h) echo "usage: start-update.sh [args]"
           exit 1
	    ;;
	:) echo "Error: -$OPTARGS requires an argument"
	   exit 1
	    ;;
        w) publish=y
	    ;;
	s) subpath=$OPTARG
            ;;
	?) echo "Error: unknown option -$OPTARG"
        esac
done

if [ -z "$subpath" ]; then
   echo "Error: you must specify a subpath name using -s"   
   exit 1
fi


# strip trailing slash from subpath
subpath="${subpath%/}"

echo starting cvmfs update

USER_HOME=$(eval echo ~${SUDO_USER})
echo ${USER_HOME}

scriptpath="${USER_HOME}/public/cvmfs"  # ASSUMING THIS IS A PUBLICLY ACCESSIBLE DIRECTORY
scriptname="update-cvmfs.sh"

mkdir -p $scriptpath
svn co svn+ssh://svn.cern.ch/reps/GENSER/doc/cvmfs/ $scriptpath   # ASSUMING THE CURRENT USER CAN SVN+SSH FROM THERE

## CONNECTING TO CVMFS-SFT, CHECKING IF NO ONE IS UPDATING REPOSITORY AND RUNNING RSYNC-SCRIPT,
## ASSUMING THE CURRENT USER CAN SSH TO CVMFS-SFT AND MAY LOG IN AS SHARED

ssh -n cvmfs-sft.cern.ch "\
echo '#!/bin/bash' >cvmfs-run-update.sh
echo 'lockfile cvmfs.lock' >>cvmfs-run-update.sh
echo 'sharedcnt=\"\$(pgrep -fl -u shared | wc -l)\"' >> cvmfs-run-update.sh
echo 'if [[ \"\$sharedcnt\" != \"0\" ]]; then' >> cvmfs-run-update.sh
echo 'echo SOMEONE IS UPDATING REPOSITORY! QUITTING EXECUTION' >> cvmfs-run-update.sh
echo 'exit 1'>> cvmfs-run-update.sh
echo ' fi ' >> cvmfs-run-update.sh
echo 'echo STARTING RSYNC SCRIPT' >> cvmfs-run-update.sh
echo 'sudo -i -u shared \$1 \$2' >> cvmfs-run-update.sh
if [ "$publish" == "y" ]; then
echo 'sudo -i -u shared cvmfs_server publish' >> cvmfs-run-update.sh
fi 
echo 'rm cvmfs.lock' >> cvmfs-run-update.sh

ssh -n cvmfs-sft.cern.ch '. cvmfs-run-update.sh $scriptpath/$scriptname $subpath'; rm cvmfs-run-update.sh"
