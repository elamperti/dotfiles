#!/bin/bash

get_name() { echo "Node.js"; }
get_desc() { echo "Current stable version, along with n, npm, and tools"; }

pushd ".." &>/dev/null
source "bundle-tools.sh"
popd &>/dev/null

verify_requirements() {
    if ! cmd_exists "git"; then
        exit 1
    fi
}

on_init() {
    if ! cmd_exists "make"; then
        send_cmd enqueue_packages "build-essential"
    fi
}

after_installs() {
    # Create a temp dir and clone n into it
    local n_tmp=$(mktemp -d)
    git clone https://github.com/tj/n.git "${n_tmp}" --depth=1 &>/dev/null

    # Enter n source directory and make it
    pushd "${n_tmp}" &>/dev/null
    sudo make install &>/dev/null
    print_install_outcome $? "n" || exit 1
    popd &>/dev/null

    # Install current stable version of Node
    sudo n stable &>/dev/null
    print_install_outcome $? "node" || exit 1

    # Install npm
    if cmd_exists "node"; then
        local npm_tmp=$(mktemp -d)
        git clone https://github.com/isaacs/npm.git "${npm_tmp}" --depth=1 &>/dev/null

        pushd "${npm_tmp}" &>/dev/null
        sudo make install &>/dev/null
        print_install_outcome $? "npm"
        popd &>/dev/null
    fi

    # Installs useful packages globally
    if cmd_exists "npm"; then
        sudo npm install -g nodemon yarn eslint &>/dev/null
        if [ $? -eq 0 ]; then
            yarn config set -- --emoji true
            send_cmd log OK "npm packages"
        else
            send_cmd log WARN "there was a problem installing npm packages"
        fi
    fi

    # Expand inodes watch limit to avoid strange errors in the future
    echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

    # Remove temp folders
    sudo rm -rf "${n_tmp}" "${npm_tmp}"  &>/dev/null
    exit 0
}

# Params: retval, thing-being-installed
# Returns: retval
print_install_outcome() {
    if [ $1 -eq 0 ]; then
        send_cmd log OK "$2 installed"
    else
        send_cmd log ERROR "$2 installation FAILED"
    fi
    return $1
}

# The following line is necessary.
# It allows bundles to be called without being sourced.
$@
