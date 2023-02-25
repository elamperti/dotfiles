#!/usr/bin/env bash

# Just in case it isn't defined
export DISPLAY="${DISPLAY:-:0}"

# Source my config
xkbcomp -w 0 -I"$HOME/.xkb" -R"$HOME/.xkb" "$HOME/.xkbrc" $DISPLAY

# Avoid default cursor in root window
# https://wiki.archlinux.org/title/Cursor_themes#Change_X_shaped_default_cursor
xsetroot -cursor_name left_ptr

# No bell
xset -b

# Disable display power management
xset s off -dpms

xrdb -merge ~/.Xresources

# Start a lightweight X settings daemon
xsettingsd &
