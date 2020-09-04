#!/bin/bash

set -e

REPO="https://github.com/zeek/zeek.git"
VER="$1"

echo "Checking out '$1'"

if [ -z "$VER" ] || [[ "$VER" == "latest" ]]; then
    VER="master"
elif [[ "$VER" == "script_optimizer" ]]; then
    VER="topic/vern/script-opt"
fi

git clone --recursive -b "$VER" --depth 1 "$REPO"
