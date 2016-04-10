#!/bin/bash

get_name() { echo "Marker"; }
get_desc() { echo "terminal command palette"; }

pushd ".." &>/dev/null
source "bundle-tools.sh"
popd &>/dev/null

verify_requirements() {
    # ToDo: Verify Python version is compatible
    if ! cmd_exists "python"; then
        exit 1
    fi
}

on_init() {
    exit 0
}

after_installs() {
    if [ ! -d ~/.marker ]; then
        mkdir ~/.marker && cd ~/.marker
        git clone https://github.com/pindexis/marker . &> /dev/null \
            && ./install.py &> /dev/null
    else
        send_cmd log ERROR "Marker folder was already present. Aborting."
        exit 1
    fi
}

# The following line is necessary.
# It allows bundles to be called without being sourced.
$@
