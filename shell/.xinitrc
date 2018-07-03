#!/usr/bin/env bash

# Just in case it isn't defined
export DISPLAY="${DISPLAY:-:0}"

# Source my config
xkbcomp -w 0 -I"$HOME/.xkb" -R"$HOME/.xkb" "$HOME/.xkbrc" $DISPLAY

# No bell
xset -b

touch /tmp/funcionaLALAA
