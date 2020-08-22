#!/usr/bin/env bash

function convert_image_name_to_tag() {
    declare -A NAMES
    NAMES["latest"]=master

    NAMES+=( ["centos:7"]=centos_7 ["centos:8"]=centos_8 )

    NAMES+=( ["ubuntu:18.04"]=ubuntu_18 ["ubuntu:20.04"]=ubuntu_20 )

    NAMES+=( ["registry.redhat.io/rhscl/devtoolset-7-toolchain-rhel7"]=rhel_7 ["registry.redhat.io/ubi8/ubi"]=rhel_8 )

    echo ${NAMES[$1]}
}

convert_image_name_to_tag "$1"
