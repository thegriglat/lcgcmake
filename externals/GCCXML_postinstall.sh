#!/bin/sh
#post-install macro to make gccxml_config relocatable 

sed -i.bak "1s/.*/GCCXML_COMPILER=\"c\+\+\"/" $1/share/gccxml-0.9/gccxml_config
rm $1/share/gccxml-0.9/gccxml_config.bak
