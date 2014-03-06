#!/bin/sh
#post-install macro to make Python-config relocatable 

# replace absolute pythonpath by relative one
location="\#\!\/usr\/bin\/env python"

sed -i.bak "1s/.*/$location/" $1/bin/python-config
rm $1/bin/python-config.bak
