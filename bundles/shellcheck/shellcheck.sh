#!/bin/bash

get_name() { echo "ShellCheck"; }
get_desc() { echo "shell static analysis tool"; }

pushd ".." &>/dev/null
source "bundle-tools.sh"
popd &>/dev/null

verify_requirements() {
    exit 0
}

on_init() {
    if ! cmd_exists "cabal"; then
        send_cmd enqueue_packages "cabal-install"
    fi
}

after_installs() {
    local temp_dir=`mktemp -d`
    send_cmd log INFO "Downloading ShellCheck..."
    git clone https://github.com/koalaman/shellcheck.git "${temp_dir}" \
        --depth=1 &>/dev/null || exit 1

    cd "$temp_dir"
    send_cmd log INFO "Updating Cabal..."
    cabal update &>/dev/null || exit 1
    send_cmd log INFO "Compiling..."
    cabal install &>/dev/null || exit 1

    # Binary compiled, we don't need the source anymore
    rm -rf "${temp_dir}"

    send_cmd log DEBUG "Moving ShellCheck binary"
    mv -f "$HOME/.cabal/bin/shellcheck" "$HOME/bin/shellcheck" || exit 1
}

# The following line is necessary.
# It allows bundles to be called without being sourced.
$@
