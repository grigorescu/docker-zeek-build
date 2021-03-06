#!/bin/bash

set -e

source $WORKSPACE/scripts/utils.sh

FLAVOR=""
PKG_CMD="None"

if command -v apt &> /dev/null; then
    PKG_CMD="apt"
    UPDATE_CMD="update"
    FLAVOR="Debian"
elif command -v yum &> /dev/null; then
    PKG_CMD="yum"
    UPDATE_CMD="makecache"
    FLAVOR="RedHat"
fi

if ! $PKG_CMD $UPDATE_CMD 2> /dev/null; then
    SUDO_ASKPASS=/bin/true sudo -vn 2> /dev/null || die "Could not run sudo."
    PKG_CMD="sudo -n $PKG_CMD"
    $PKG_CMD $UPDATE_CMD || die "Could not run package manager."
fi

# Given an argument, install that
if [ ! -z "$1" ]; then
    $PKG_CMD install -y $1
    exit 0
fi

# Otherwise install what we think we need
if [ $FLAVOR == "Debian" ]; then
    export DEBIAN_FRONTEND="noninteractive"
    $PKG_CMD install -y bison build-essential cmake curl flex g++ gawk gcc libjemalloc-dev libkrb5-dev libmaxminddb-dev libpcap-dev libssl-dev make python3-dev python3-pip ruby ruby-dev rubygems sendmail swig zlib1g-dev
elif [ $FLAVOR == "RedHat" ]; then
    # libpcap-devel moved to the PowerTools repo in CentOS 8
    if [ $(rpm -E %{rhel}) == "8" ]; then
        $PKG_CMD install -y dnf-plugins-core epel-release
        ${PKG_CMD} config-manager --set-enabled powertools
    else
        if [ -f zeek/cmake/RequireCXX17.cmake ] || grep '2.5' zeek/VERSION; then
            # C++ 17
            $PKG_CMD install -y scl-utils centos-release-scl epel-release
            $PKG_CMD install -y devtoolset-7-gcc*
        else
            $PKG_CMD install -y epel-release
        fi
    fi

    $PKG_CMD install -y autoconf automake bison cmake3 curl file-devel flex gcc gcc-c++ jemalloc-devel krb5-devel libmaxminddb-devel libpcap-devel libtool make ncurses-devel openssl-devel ruby-devel rubygems rpm-build sendmail swig which zlib-devel
    $PKG_CMD install -y python3-devel python3-pip || $PKG_CMD install -y python-devel python-pip cmake
fi

if ! pip3 install zkg; then
    pip install zkg || echo "Could not install pip. Continuing anyway."
fi

if ! gem install --no-document fpm -f; then
    # CentOS 6
    $PKG_CMD install -y scl-utils centos-release-SCL
    $PKG_CMD install -y rh-ruby23-ruby rh-ruby23-ruby-devel
    echo "gem install --no-document fpm -f" | scl enable rh-ruby23 - || echo "Could not install fpm. Continuing anyway."
fi
