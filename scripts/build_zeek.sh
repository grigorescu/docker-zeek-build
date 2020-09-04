#!/bin/bash

set -e

ncores=$(grep '^processor' /proc/cpuinfo | sort -u | wc -l)
MAKE_OPTS="-j -l $ncores"

if grep -q -- --enable-jemalloc zeek/configure &> /dev/null; then
    CONF_OPTS="--enable-jemalloc"
else
    CONF_OPTS=""
fi

if [ ! -z $ZEEK_PREFIX ]; then
    CONF_OPTS="$CONF_OPTS --prefix=$ZEEK_PREFIX"
elif [ ! -z $BRO_PREFIX ]; then
    CONF_OPTS="$CONF_OPTS --prefix=$BRO_PREFIX"
fi

if grep -q -- --with-python zeek/configure && command -v python3 &> /dev/null; then
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
        --slave /usr/local/bin/ccmake ccmake /usr/bin/ccmake || true

        alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake3 20 \
        --slave /usr/local/bin/ctest ctest /usr/bin/ctest3 \
        --slave /usr/local/bin/cpack cpack /usr/bin/cpack3 \
        --slave /usr/local/bin/ccmake ccmake /usr/bin/ccmake3 || true
    fi
fi


cd zeek

# Bro 1.x
if [ -f configure.in ]; then
    autoconf
else
    # Older versions will fail without this. Newer versions use the correct syntax.
    sed -i '1s/^/cmake_policy(SET CMP0004 OLD)\n/' CMakeLists.txt || (echo "Could not set cmake policy"; cat CMakeLists.txt || true)
fi

if command -v rpm && [ $(rpm -E %{rhel}) == "7" ] && [ -f cmake/RequireCXX17.cmake ]; then
    echo "./configure $CONF_OPTS" | scl enable devtoolset-7 -
else
    ./configure $CONF_OPTS
fi
make $MAKE_OPTS
make install
