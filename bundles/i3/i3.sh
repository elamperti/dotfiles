#!/bin/bash

get_name() { echo "i3"; }
get_desc() { echo "i3 window manager with custom setup"; }

pushd ".." &>/dev/null
source "bundle-tools.sh"
popd &>/dev/null

verify_requirements() {
    if ! cmd_exists "wget"; then
        exit 1
    fi
}

on_init() {
    if ! cmd_exists "add-apt-repository"; then
        send_cmd log INFO "Installing add-apt-repository..."
        sudo apt-get install software-properties-common python-software-properties &> /dev/null
    fi

    sudo add-apt-repository -y ppa:snwh/ppa &> /dev/null # for icons

    sudo apt-get update &> /dev/null

    send_cmd enqueue_packages "moka-icon-theme" # snwh/ppa

    send_cmd log DEBUG "Downloading FA5 fonts..."
    local FONTAWESOME_VERSION="5.3.1"
    wget -O ~/.fonts/fa-regular-400.otf "https://github.com/FortAwesome/Font-Awesome/blob/${FONTAWESOME_VERSION}/use-on-desktop/Font%20Awesome%205%20Free-Regular-400.otf?raw=true"
    wget -O ~/.fonts/fa-solid-900.otf "https://github.com/FortAwesome/Font-Awesome/blob/${FONTAWESOME_VERSION}/use-on-desktop/Font%20Awesome%205%20Free-Solid-900.otf?raw=true"
    wget -O ~/.fonts/fa-brands-400.otf "https://github.com/FortAwesome/Font-Awesome/blob/${FONTAWESOME_VERSION}/use-on-desktop/Font%20Awesome%205%20Brands-Regular-400.otf?raw=true"

    send_cmd log DEBUG "Downloading Yosemite San Francisco fonts..."
    wget -O ~/.fonts/"System San Francisco Display Regular.ttf" "https://github.com/supermarin/YosemiteSanFranciscoFont/blob/master/System%20San%20Francisco%20Display%20Regular.ttf?raw=true"
    wget -O ~/.fonts/"System San Francisco Display Bold.ttf" "https://github.com/supermarin/YosemiteSanFranciscoFont/blob/master/System%20San%20Francisco%20Display%20Bold.ttf?raw=true"
    wget -O ~/.fonts/"System San Francisco Display Thin.ttf" "https://github.com/supermarin/YosemiteSanFranciscoFont/blob/master/System%20San%20Francisco%20Display%20Thin.ttf?raw=true"
    wget -O ~/.fonts/"System San Francisco Display Ultralight.ttf" "https://github.com/supermarin/YosemiteSanFranciscoFont/blob/master/System%20San%20Francisco%20Display%20Ultralight.ttf?raw=true"

    # send_cmd enqueue_packages "i3blocks"
    send_cmd enqueue_packages "conky"
    send_cmd enqueue_packages "python-dbus" # so conky can display currently played song
    send_cmd enqueue_packages "pasystray" # Volume control in tray
    send_cmd enqueue_packages "rofi"

    send_cmd enqueue_packages "arc-theme"
    send_cmd enqueue_packages "moka-icon-theme"

    # All this to compile i3gaps
    send_cmd enqueue_packages "libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev autoconf libxcb-xrm-dev libxcb-shape0-dev"
}

after_installs() {
    send_cmd log INFO "Building i3-gaps..."
    git clone "https://www.github.com/Airblader/i3.git" /tmp/i3gaps &>/dev/null
    pushd /tmp/i3gaps &>/dev/null
        autoreconf --force --install &>/dev/null && \
        rm -rf /tmp/i3gaps/build/
        mkdir -p /tmp/i3gaps/build/ &&
        pushd /tmp/i3gaps/build &>/dev/null
            ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers &>/dev/null && \
            make &>/dev/null && \
            sudo make install &>/dev/null || send_cmd log WARN "Failed to compile i3-gaps"
        popd &>/dev/null
    popd &>/dev/null
}

# The following line is necessary.
# It allows bundles to be called without being sourced.
$@
