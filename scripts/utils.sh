#!/bin/bash

function die {
    if [ ! -z "$1" ]; then
        echo "$1"
    fi

    exit 1
}
