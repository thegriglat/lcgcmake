#!/bin/bash -e

bindir=$1
srcdir=$2
proc=$3

mkdir -p $proc
cd $proc
rm -rf *

# lookup example steering files
example=""
for i in test testrun-lhc testrun-b-lhc testrun test-lhc testrun-wp-lhc test-el ; do
  if [ -d $srcdir/$proc/$i ] ; then
    example="$srcdir/$proc/$i"
    break
  fi
done

if [[ "$example" = "" ]] ; then
  "ERROR: failed to find example steering cards at $srcdir/$proc"
  exit 1
fi

echo "INFO: example steering files = $example"

# copy process example run cards
cp $example/* .

if [ ! -e powheg.input ] ; then
  ln -s $(find *.input | head -n 1) powheg.input
fi

# reduce events number
sed -i powheg.input \
    -e 's,numevts.*,numevts 100,' \
    -e 's,ncall1.*,ncall1 1000,' \
    -e 's,itmx1.*,itmx1 1,' \
    -e 's,ncall2.*,ncall2 1000,' \
    -e 's,itmx2.*,itmx2 1,' \
    -e 's,nubound.*,nubound 1000,' \
    -e 's,manyseeds.*,manyseeds 0,'

if [[ "$proc" == "W_ew-BMNNP" || "$proc" == "VBF_Wp_Wp" ]] ; then
  # add missing PDF set
  cp $srcdir/Z/testrun-lhc/cteq6m .
fi

# run the test
$bindir/$proc

# check the test completed succesfully
# (generated required number of events)
ngen=$(grep "<event>" pwgevents.lhe | wc -l)
if [[ "$ngen" != "100" ]] ; then
  echo "ERROR: generator $proc is failed to generate 100 events"
  exit 1
fi

echo "Test completed succesfully. See outout in $proc/"
