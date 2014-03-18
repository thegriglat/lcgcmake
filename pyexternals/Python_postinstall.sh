#!/bin/sh
#post-install macro to make Python-executables relocatable 

# replace absolute pythonpath by relative one
location="\#\!\/usr\/bin\/env python"

for line in `find $1/bin -iname '*'`; do
  echo "Patching $line for relocatability"
  sed -i.bak "1s/.*/$location/" $line
  rm $line.bak 
done

