#!/bin/bash

set -e

ncores=$(grep '^processor' /proc/cpuinfo | sort -u | wc -l)
MAKE_OPTS="-j -l $ncores"

CONF_OPTS="--enable-jemalloc --binary-package --enable-static-broker --enable-static-binpac"

if [ ! -z $ZEEK_PREFIX ]; then
    CONF_OPTS="$CONF_OPTS --prefix=$ZEEK_PREFIX"
fi

if command -v python3 &> /dev/null; then
    CONF_OPTS="$CONF_OPTS --with-python=$(which python3)"
fi

# RedHat distros install cmake3 under that name, making Zeek unable to find it.
if ! command -v cmake &> /dev/null; then
    if grep -q -- --cmake zeek/configure && command -v cmake &> /dev/null; then
        CONF_OPTS="$CONF_OPTS --cmake=$(which cmake3)"
    else
        # https://stackoverflow.com/a/48842999
        alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake 10 \
        --slave /usr/local/bin/ctest ctest /usr/bin/ctest \
        --slave /usr/local/bin/cpack cpack /usr/bin/cpack \
        --slave /usr/local/bin/ccmake ccmake /usr/bin/ccmake \
        --family cmake

        alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake3 20 \
        --slave /usr/local/bin/ctest ctest /usr/bin/ctest3 \
        --slave /usr/local/bin/cpack cpack /usr/bin/cpack3 \
        --slave /usr/local/bin/ccmake ccmake /usr/bin/ccmake3 \
        --family cmake
    fi
fi


cd zeek
./configure $CONF_OPTS
make $MAKE_OPTS
make install
