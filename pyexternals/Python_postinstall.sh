#!/bin/bash
#post-install macro to make Python-executables relocatable 

# replace absolute pythonpath by relative one
location="\#\!\/usr\/bin\/env python"

for line in `find $1/bin -iname '*'`; do
  if head -n1 $line | grep -q "/python" ; then
    echo "Patching $line for relocatability"
    sed -i.bak -e "1s/.*/$location/" $line
    rm $line.bak 
  fi
done

