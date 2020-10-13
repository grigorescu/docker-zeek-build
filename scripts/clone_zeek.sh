#!/bin/bash

set -e

REPO="https://github.com/zeek/zeek.git"
VER="$1"

echo "Checking out '$1'"

if [ -z "$VER" ] || [[ "$VER" == "latest" ]]; then
    VER="master"
elif [[ "$VER" == "release/1.5" ]]; then
    curl -o bro.tar.gz https://download.zeek.org/bro-1.5.3.tar.gz
    tar xvzf bro.tar.gz
    mv bro-1* zeek
elif [[ "$VER" == "preview" ]]; then
    VER="v3.3.0-dev"
elif [[ "$VER" == "script_optimizer" ]]; then
    VER="topic/vern/script-opt"
fi

git clone --recursive -b "$VER" --depth 1 "$REPO"
cd zeek
echo "Checked out Zeek commit $(git rev-parse HEAD)"
