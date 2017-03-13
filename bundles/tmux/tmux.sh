#!/bin/bash

get_name() { echo "Tmux"; }
get_desc() { echo "terminal multiplexer (latest)"; }

pushd ".." &>/dev/null
source "bundle-tools.sh"
popd &>/dev/null

verify_requirements() {
    if ! cmd_exists "dpkg"; then
        # What the hell? dpkg?! Come on, this is not even using a deb package!
        # Calm down. It's just because I use it to compare versions on `needs_update()`
        # ToDo: implement a version comparator or research `sort -V` usability
        exit 1
    fi
}

needs_update() {
    cmd_exists "tmux" || return 0

    local remote_ver=$(wget -qO- https://tmux.github.io/|grep -osP -m1 "http.*\.tar\.gz"|grep -osP "(?<=\/)\d[^/]+")
    local local_ver=$(tmux -V|grep -osP "[0-9].*")

    dpkg --compare-versions "${remote_ver}" "gt" "${local_ver}"
    return $?
}

on_init() {
    if needs_update; then
        send_cmd enqueue_packages build-essential
        send_cmd enqueue_packages libevent-dev
        send_cmd enqueue_packages libncurses5-dev
    else
        send_cmd log INFO "tmux up to date"
    fi
}

after_installs() {
    send_cmd log INFO "Verifying tmux version"
    if needs_update; then
        # Fetches tmux download page and greps the latest package URL
        local pkgurl=$(wget -qO- https://tmux.github.io/|grep -osP -m1 "http.*\.tar\.gz")
        local tmux_package="$(mktemp tmux-XXXXXX.tar.gz --tmpdir=/tmp)"
        local tmux_path="$(mktemp -d tmux-XXXXXX --tmpdir=/tmp)"
        local install_outcome=0 # Assume it's all good. Trust me, I'm a programmer.
        local pkg_version=$(echo ${pkgurl}|grep -osP "(?<=\/)\d[^/]+")

        send_cmd log INFO "Downloading..."
        send_cmd log DEBUG "Downloading tmux ${pkg_version} from: $pkgurl"
        wget -qO "${tmux_package}" "$pkgurl"
        [ ! $? ] && send_cmd log ERROR "Error downloading package" && exit 1

        send_cmd log DEBUG "Extracting..."
        tar xzf "${tmux_package}" -C "${tmux_path}"
        pushd "${tmux_path}"/tmux*/ &>/dev/null

        send_cmd log INFO "Preparing for installation..."
        ./configure &>/dev/null && make &>/dev/null

        if [ $? ]; then
            send_cmd log INFO "Installing..."
            sudo make install &>/dev/null
            install_outcome=$?
        else
            send_cmd log ERROR "Problem configuring build"
            install_outcome=1
        fi

        popd &>/dev/null

        send_cmd log INFO "Downloading Tmux Plugin Manager..."
        git clone "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm" --depth=1

        exit ${install_outcome}
    else
        send_cmd log NOTICE "Already up to date."
        exit 0
    fi
}

# The following line is necessary.
# It allows bundles to be called without being sourced.
$@
