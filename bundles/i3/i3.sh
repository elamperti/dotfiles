#!/bin/bash

get_name() { echo "i3"; }
get_desc() { echo "i3 window manager with custom setup (Debian)"; }

pushd ".." &>/dev/null
source "bundle-tools.sh"
popd &>/dev/null

verify_requirements() {
    if ! cmd_exists "wget"; then
        exit 1
    fi
}

on_init() {
    send_cmd enqueue_packages "i3-wm"

    local FONTAWESOME_VERSION="5.15.4"
    send_cmd log DEBUG "Downloading FontAwesome (v${FONTAWESOME_VERSION})..."
    wget -qO ~/.fonts/fa-regular-400.otf "https://github.com/FortAwesome/Font-Awesome/blob/${FONTAWESOME_VERSION}/otfs/Font%20Awesome%205%20Free-Regular-400.otf?raw=true"
    wget -qO ~/.fonts/fa-solid-900.otf   "https://github.com/FortAwesome/Font-Awesome/blob/${FONTAWESOME_VERSION}/otfs/Font%20Awesome%205%20Free-Solid-900.otf?raw=true"
    wget -qO ~/.fonts/fa-brands-400.otf  "https://github.com/FortAwesome/Font-Awesome/blob/${FONTAWESOME_VERSION}/otfs/Font%20Awesome%205%20Brands-Regular-400.otf?raw=true"

    send_cmd enqueue_packages "conky"
    send_cmd enqueue_packages "python-dbus" # so conky can display currently played song
    send_cmd enqueue_packages "dunst" # To show notifications
    send_cmd enqueue_packages "pasystray" # Volume control in tray
    send_cmd enqueue_packages "rofi" # for a spotlight-like menu
    send_cmd enqueue_packages "feh" # To change background
    send_cmd enqueue_packages "scrot" # To take screenshots
    send_cmd enqueue_packages "sox" # To make screenshot sound
    send_cmd enqueue_packages "xdotool" # Used to toggle terminal window
    send_cmd enqueue_packages "xcape" # Map Super to Alt+F1
    send_cmd enqueue_packages "imwheel" # Mouse behavior configuration
    send_cmd enqueue_packages "numlockx" # Numlock toggler
    send_cmd enqueue_packages "xorg-xsetroot"

    send_cmd enqueue_packages "arc-theme"
    send_cmd enqueue_packages "moka-icon-theme"

    send_cmd enqueue_packages "otf-san-francisco" # Font
    send_cmd enqueue_packages "whitesur-gtk-theme" # Theme #ToDo: auto-config?
    # send_cmd enqueue_packages "whitesur-icon-theme-git" # Icons

    send_cmd enqueue_packages "lightdm-slick-greeter"
    send_cmd enqueue_packages "lightdm-settings"
    send_cmd enqueue_packages "accountsservice" # d-bus service, to show user avatars
    # greeter-session=lightdm-lightdm-slick-greeter in /etc/lightdm/lightdm.conf

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
