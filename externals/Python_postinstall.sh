#!/bin/sh
#post-install macro to make Python-config relocatable 

# replace absolute pythonpath by relative one
location="\#\!\/usr\/bin\/env python"

sed -i "1s/.*/$location/" $1/bin/python-config

