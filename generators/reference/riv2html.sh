#!/bin/bash

echo arguments:
echo $1
echo $2
echo $3
echo $4
echo end arguments

source $1/rivetenv.sh

rivet-mkhtml -o $4 -s --mc-errs $2:'Title=Reference' $3:'LineColor=blue'
