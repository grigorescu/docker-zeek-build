#!/usr/bin/env bash

function convert_image_name_to_tag() {
    declare -A NAMES
    NAMES["latest"]=master

    NAMES+=( ["centos:6"]=centos_6 ["centos:7"]=centos_7 ["centos:8"]=centos_8 )

    NAMES+=( ["ubuntu:18.04"]=ubuntu_18 ["ubuntu:20.04"]=ubuntu_20 )

    echo ${NAMES[$1]}
}

convert_image_name_to_tag "$1"
