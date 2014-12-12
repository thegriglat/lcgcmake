#!/bin/sh
#post-install macro to make GSL relocatable

# 1) remove .la files
rm -f $1/lib/*.la

# 2) replace absolute prefix by relative one in gsl-config
sed -i.bak -e "s:$1:\$(dirname \$(dirname \$0)):" $1/bin/gsl-config
