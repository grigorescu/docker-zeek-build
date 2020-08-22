#!/bin/bash

set -e

REPO="https://github.com/zeek/zeek.git"
VER="$1"

if [ -z "$VER" ] || ["$VER" == "latest" ]; then
    VER="master"
fi

git clone --recursive -b "$VER" --depth 1 "$REPO"
