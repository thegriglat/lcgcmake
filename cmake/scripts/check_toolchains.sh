#!/bin/sh

source /afs/cern.ch/sw/lcg/external/gcc/4.9/x86_64-slc6-gcc49-opt/setup.sh
export PATH=/afs/cern.ch/sw/lcg/contrib/CMake/2.8.12.2/Linux-i386/bin:${PATH}

WORKDIR=/tmp/${USER}/testlcg

mkdir -p ${WORKDIR}
cd ${WORKDIR}
rm -rf *

svn co svn+ssh://svn.cern.ch/reps/lcgsoft/trunk/lcgcmake

for TOOLCHAIN in dev2 dev3 dev4 experimental 67b 67c 61f 64d 71 71root6 73root6 74root6 75root6 geantv rootext
do
    echo -n " Checking toolchain ${TOOLCHAIN}..... "
    mkdir ${WORKDIR}/build_${TOOLCHAIN}
    cd ${WORKDIR}/build_${TOOLCHAIN}
cmake -DLCG_VERSION=${TOOLCHAIN} -DCMAKE_INSTALL_PREFIX=../install -DPDFsets=minimal -DLCG_SAFE_INSTALL=ON -DLCG_TARBALL_INSTALL=false -DCMAKE_BUILD_TYPE:STRING=Release ../lcgcmake >& ../out_lcgconfigure_${TOOLCHAIN}
    status=$?
    if [ $status -ne 0 ]; then
        echo "error"
    else
        echo "OK!"	
    fi
done




