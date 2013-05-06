#!/bin/sh -e

./configure $@
source ./setupEnvVariables.sh
g++ -v
make slib
