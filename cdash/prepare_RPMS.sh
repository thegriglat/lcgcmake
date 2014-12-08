#!/bin/bash

#Script to prepare the RPMS for an LCG release
#Accepting following parameters:
#  $1: workdir
#  $2: platform (like x86_64-slc6-gcc49-opt)  
#  $3: version (of LCG to build)
WORKDIR="$1"
PLATFORM="$2"
LCG_VERSION="$3"

# useful variables
SCRIPTDIR=${WORKDIR}/lcg-scripts
RPM_SCRIPTDIR=/afs/cern.ch/sw/lcg/app/spi/tools/LCGRPM/package
RPM_TMPDIR=${WORKDIR}/${PLATFORM}-rpms

# the RPM revision is the numeric part of the LCG release
RPM_REVISION=`expr "$LCG_VERSION" : '\(.[0-9]\)'`

# Here the actual procedure starts: 
echo "Preparing rpms for LCG ${LCG_VERSION} on ${PLATFORM} from contents of ${WORKDIR}."

cd $WORKDIR/${PLATFORM}-install
$SCRIPTDIR/extract_LCG_summary.py . $PLATFORM ${LCG_VERSION} RELEASE
${RPM_SCRIPTDIR}/createLCGRPMSpec.py LCG_externals_${PLATFORM}.txt -b ${RPM_TMPDIR} -o externals.spec --release ${RPM_REVISION}
${RPM_SCRIPTDIR}/createLCGRPMSpec.py LCG_generators_${PLATFORM}.txt -b ${RPM_TMPDIR} -o generators.spec --release ${RPM_REVISION}
rpmbuild -bb externals.spec
rpmbuild -bb generators.spec

echo "Finished building RPMS in ${RPM_TMPDIR}."
