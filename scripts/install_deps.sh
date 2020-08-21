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
    UPDATE_CMD="updateinfo"
    FLAVOR="RedHat"
fi

if ! $PKG_CMD $UPDATE_CMD 2> /dev/null; then
    SUDO_ASKPASS=/bin/true sudo -vn 2> /dev/null || die "Could not run sudo."
    PKG_CMD="sudo -n $PKG_CMD"
    $PKG_CMD $UPDATE_CMD || die "Could not run package manager."
fi

if [ $FLAVOR == "Debian" ]; then
    $PKG_CMD install -y bison cmake curl flex g++ gcc git libgoogle-perftools-dev libjemalloc-dev libkrb5-dev libmaxminddb-dev libpcap-dev libssl-dev make python-dev sendmail swig zlib1g-dev
elif [ $FLAVOR == "RedHat" ]; then
    $PKG_CMD install -y bison cmake curl flex gcc gcc-c++ git jemalloc krb5-devel libmaxminddb-devel libpcap-devel make openssl-devel python-devel sendmail swig zlib-devel
fi
