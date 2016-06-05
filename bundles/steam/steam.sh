#!/bin/bash

get_name() { echo "Steam"; }
get_desc() { echo "Valve's game platform"; }

pushd ".." &>/dev/null
source "bundle-tools.sh"
popd &>/dev/null

verify_requirements() {
    exit 0
}

on_init() {
    send_cmd enqueue_packages "libgl1-mesa-dri:i386" "libgl1-mesa-glx:i386" "libc6:i386"
}

after_installs() {
    local steam_package="/tmp/steam_latest.deb"

    send_cmd log INFO "Downloading Steam client..."
    curl --silent -kfLo "${steam_package}" \
        "https://steamcdn-a.akamaihd.net/client/installer/steam.deb"

    # Verify if curl threw an error
    if [ ! $? ]; then
        send_cmd log ERROR Download failed
        exit 1
    fi

    send_cmd log INFO "Installing Steam package..."
    sudo dpkg -i ${steam_package} &>/dev/null || exit 1
}

# The following line is necessary.
# It allows bundles to be called without being sourced.
$@
