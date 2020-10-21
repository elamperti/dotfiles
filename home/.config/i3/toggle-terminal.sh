#!/bin/sh

DROPDOWN_CLASS="quakitty"

if xdotool search --limit 1 --class $DROPDOWN_CLASS 1>/dev/null 2>/dev/null; then
  if ! i3-msg -q "[class=\"$DROPDOWN_CLASS\"] scratchpad show"; then
    i3-msg -q "[class=\"$DROPDOWN_CLASS\"] move scratchpad"
  fi
else
  kitty --single-instance --class $DROPDOWN_CLASS 1>/dev/null 2>/dev/null &
fi
