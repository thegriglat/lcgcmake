#!/bin/bash
# post-install macro to make Python-config and _sysconfigdata.py relocatable
# usage:  postinstall <INSTALL_DIR>

# replace absolute pythonpath by relative one
location="\#\!\/usr\/bin\/env python"

sed -i.bak "1s/.*/$location/" $1/bin/python-config
rm $1/bin/python-config.bak

nam=$(basename `readlink -f $1/bin/python`)
sed -i '1iimport os; installdir=os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))' $1/lib/$nam/_sysconfigdata.py
sed -i "s:'$1:installdir + ':g" $1/lib/$nam/_sysconfigdata.py

