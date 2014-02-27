#!/bin/sh
#post-install macro to make Qt relocatable 

cat >| $1/bin/qt.conf <<EOF
[Paths]
Prefix=..
EOF


