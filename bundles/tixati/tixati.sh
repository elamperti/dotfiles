#!/bin/bash

get_name() { echo "Tixati"; }
get_desc() { echo "latest version of this BitTorrent client"; }

pushd ".." &>/dev/null
source "bundle-tools.sh"
popd &>/dev/null

verify_requirements() {
    if ! cmd_exists "wget"; then
        exit 1
    fi

    local arch=$(uname -i)
    if [[ ! "$arch" == "x86_64" || "$arch" == "amd64" || "$arch" == "i686" ]]; then
        send_cmd log ERROR "Unsupported architecture ${arch}"
        exit 1
    fi
}

on_init() {
    exit 0
}

after_installs() {
    # At this assume this is a valid architecture. Replace x86_64 with amd64.
    local arch=$(uname -i); [ "$arch" == "x86_64" ] && arch="amd64"

    # Fetches Tixati download page and greps the latest deb package URL
    local pkgurl=$(wget -qO- https://www.tixati.com/download/linux.html|grep -oP "http.*?_${arch}.deb"|awk '!_[$0]++')
    tixati_package="$(mktemp tixati-XXXXXX.deb --tmpdir=/tmp)"

    send_cmd log INFO "Downloading Tixati..."
    send_cmd log DEBUG "Downloading Tixati from: $pkgurl"
    wget -qO "${tixati_package}" "$pkgurl"
    [ ! $? ] && send_cmd log ERROR "Error downloading Tixati package" && exit 1

    if cmd_exists "tixati"; then
        send_cmd log INFO "Updating"
    else
        send_cmd log INFO "Installing"
    fi
    sudo dpkg -i "$tixati_package" &>/dev/null
    if [ $? ]; then
        # send_cmd log OK "Installation successful"
        rm "$tixati_package"
    else
        exit 1
    fi
}

# The following line is necessary.
# It allows bundles to be called without being sourced.
$@
