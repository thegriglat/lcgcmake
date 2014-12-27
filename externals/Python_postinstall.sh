#!/bin/bash
# post-install macro to make Python-config and _sysconfigdata.py relocatable
# usage:  postinstall <INSTALL_DIR>

# replace absolute pythonpath by relative one
location="\#\!\/usr\/bin\/env python"

sed -i.bak "1s/.*/$location/" $1/bin/python-config
rm $1/bin/python-config.bak

if [ ! "Darwin" = $(uname -s) ];then
  nam=$(basename `readlink -f $1/bin/python`)
else
  nam=$(basename `$1/bin/python -c "import os,sys; print os.path.realpath(sys.argv[1])" $1/bin/python`)
fi
if [ -e "$1/lib/$nam/_sysconfigdata.py" ]; then
  sed -i.bak -e '1i\
import os; installdir=os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))' $1/lib/$nam/_sysconfigdata.py
  sed -i.bak -e "s:'$1:installdir + ':g" $1/lib/$nam/_sysconfigdata.py
fi
