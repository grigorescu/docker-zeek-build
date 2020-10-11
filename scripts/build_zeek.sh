#!/bin/bash

set -e

function fix_cmake {
    if [ -f "$1" ]; then
        sed -i '/cmake_minimum_required.*/a cmake_policy(SET CMP0004 OLD)' "$1" || (echo "Could not set cmake policy in $1"; cat "$1" || true)
    fi
}

ncores=$(grep '^processor' /proc/cpuinfo | sort -u | wc -l)
MAKE_OPTS="-j -l $ncores"

cd zeek

# Bro 1.x
if [ -f autogen.sh ]; then
    ./autogen.sh
else
    # Older versions will fail without this. Newer versions use the correct syntax.
    fix_cmake aux/broccoli/bindings/broccoli-python/CMakeLists.txt
    fix_cmake aux/broctl/aux/pysubnettree/CMakeLists.txt
fi

if grep -q -- --enable-jemalloc configure &> /dev/null; then
    CONF_OPTS="--enable-jemalloc"
else
    CONF_OPTS=""
fi

if [ ! -z $ZEEK_PREFIX ]; then
    CONF_OPTS="$CONF_OPTS --prefix=$ZEEK_PREFIX"
elif [ ! -z $BRO_PREFIX ]; then
    CONF_OPTS="$CONF_OPTS --prefix=$BRO_PREFIX"
fi

if grep -q -- --with-python configure &> /dev/null; then
    if egrep -q '^(1.5|2.0|2.1)' VERSION && command -v python &> /dev/null; then
        # These versions have a bug in the cmake file. Get the fixed version.
        curl -o UserChangedWarning.cmake https://raw.githubusercontent.com/zeek/cmake/e760f19aa34c38c69bab61b2af251f692c3172c5/UserChangedWarning.cmake
        mv UserChangedWarning.cmake cmake/
        CONF_OPTS="$CONF_OPTS --with-python=$(which python)"
    elif command -v python3 &> /dev/null; then
        CONF_OPTS="$CONF_OPTS --with-python=$(which python3)"
    else
        CONF_OPTS="$CONF_OPTS --with-python=$(which python)"
    fi
fi

# Use cmake3 to build Zeek 2.6 and 3.0+. Key off of the name change
if ( [ -f zeek-wrapper.in ] || grep '2.6' VERSION ) && ! command -v cmake &> /dev/null; then
    # RedHat distros install cmake3 under that name, making Zeek unable to find it.
    if grep -q -- --cmake configure && command -v cmake &> /dev/null; then
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

if command -v rpm && [ $(rpm -E %{rhel}) == "7" ] && [ -f cmake/RequireCXX17.cmake ]; then
    echo "./configure $CONF_OPTS" | scl enable devtoolset-7 -
elif grep '2.5' VERSION; then
    # 2.5 requires C++11, which isn't a thing on CentOS 6 where we build it
    echo "./configure $CONF_OPTS" | scl enable devtoolset-7 -
else
    ./configure $CONF_OPTS
fi
make $MAKE_OPTS || ( cat CMakeLists.txt; exit 1)
make install
