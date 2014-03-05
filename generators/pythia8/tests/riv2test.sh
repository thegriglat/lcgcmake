#!/bin/bash

echo arguments:
echo $1
echo $2
echo end arguments

source $1/rivetenv.sh
rivet -a MC_XS -a MC_ZJETS --histo-file=pythia8_riv2_i.yoda $2
#rivet -a CMS_2012_I1184941 $2
