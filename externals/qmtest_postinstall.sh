#!/bin/sh
#post-install macro to make QMtest relocatable 

# 1) replace absolute pythonpath by relative one in the executable
location="\#\!\/usr\/bin\/env python"

sed -i.bak "1s/.*/$location/" $1/bin/qmtest
rm $1/bin/qmtest.bak

# 2) fix config.py to be self-relative
cd $1/lib/python*/site-packages/qm
repl=`grep prefix config.py`
rm config.pyc
mv config.py config.py.org
echo "import os" > config.py
sed s%$repl%prefix=os.path.realpath\(os.path.abspath\(os.path.dirname\(__file__\)\)+\(os.sep+os.pardir\)*4\)% config.py.org >> config.py
echo >> config.py
