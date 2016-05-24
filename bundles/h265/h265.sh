#!/bin/bash

get_name() { echo "h265"; }
get_desc() { echo "HEVC/h.265 codec for gstreamer and VLC"; }

pushd ".." &>/dev/null
source "bundle-tools.sh"
popd &>/dev/null

verify_requirements() {
    exit 0
}

on_init() {
    exit 0
}

after_installs() {
    local ubuntu_version=`lsb_release -c|cut -f2`
    local ppa_url='http://ppa.launchpad.net/strukturag/libde265/ubuntu'

    if ! grep "strukturag" /etc/apt/sources.list; then
        echo "deb ${ppa_url} ${ubuntu_version} main" | sudo tee -a /etc/apt/sources.list &>/dev/null
        echo "deb-src ${ppa_url} ${ubuntu_version} main" | sudo tee -a /etc/apt/sources.list &>/dev/null
        send_cmd log NOTICE "Added strukturag/libde265 PPA to sources.list"
        send_cmd log INFO "Updating apt package list"
        sudo apt-get update &>/dev/null
    fi

    send_cmd enqueue_packages "gstreamer0.10-libde265"
    send_cmd enqueue_packages "vlc-plugin-libde265"
    exit 0
}

# The following line is necessary.
# It allows bundles to be called without being sourced.
$@
