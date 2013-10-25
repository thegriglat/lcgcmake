#!/bin/bash

source $1/rivetenv.sh

echo "LD_LIBARARY_PATH =  " ${LD_LIBRARY_PATH}
echo "PATH =  " ${PATH}
rivet --analysis=CMS_2012_I1184941 $2:
