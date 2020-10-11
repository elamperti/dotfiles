#!/usr/bin/env bash

# Just in case it isn't defined
export DISPLAY="${DISPLAY:-:0}"

# Source my config
xkbcomp -w 0 -I"$HOME/.xkb" -R"$HOME/.xkb" "$HOME/.xkbrc" $DISPLAY

# No bell
xset -b

# Turn off display after 20 minutes
xset s off
xset -dpms

xrdb -merge ~/.Xresources
