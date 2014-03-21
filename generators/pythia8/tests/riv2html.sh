#!/bin/bash

echo arguments:
echo $1
echo $2
echo end arguments

source $1/rivetenv.sh

rivet-mkhtml -o pythia8html -s --mc-errs pythia8_riv2.yoda:'Title=Reference' pythia8_riv2_i.yoda:'LineColor=blue'
