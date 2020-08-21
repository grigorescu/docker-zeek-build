#!/bin/bash

set -e

ncores=$(grep '^processor' /proc/cpuinfo | sort -u | wc -l)
MAKE_OPTS="-j -l $ncores"

CONF_OPTS="--enable-jemalloc --binary-package"

if [ ! -z $ZEEK_PREFIX ]; then
    CONF_OPTS="$CONF_OPTS --prefix=$ZEEK_PREFIX"
fi

if command -v python3 &> /dev/null; then
    CONF_OPTS="$CONF_OPTS --with-python=$(which python3)"
fi

cd zeek
./configure $CONF_OPTS
make $MAKE_OPTS

