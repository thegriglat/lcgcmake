#!/bin/sh
#post-install macro to make GSL relocatable

# 1) replace absolute prefix by relative one in gsl-config
sed "s:$1:$(dirname $(dirname $0)):" $1/bin/gsl-config
