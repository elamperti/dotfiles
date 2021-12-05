#!/bin/sh

DROPDOWN_CLASS="quakitty"

_show_kitty() {
  i3-msg -q "[class=\"$DROPDOWN_CLASS\"] scratchpad show, [class=\"$DROPDOWN_CLASS\"] move window to position 0 px 31 px, [class=\"$DROPDOWN_CLASS\"] resize set 1920px 1049px"
  return $?
}

_hide_kitty() {
  i3-msg -q "[class=\"$DROPDOWN_CLASS\"] move scratchpad"
}

if xdotool search --limit 1 --class $DROPDOWN_CLASS 1>/dev/null 2>/dev/null; then
  if ! _show_kitty; then
    _hide_kitty
  fi
else
  kitty --single-instance --class $DROPDOWN_CLASS 1>/dev/null 2>/dev/null &
  [ -n "$1" ] && _hide_kitty || _show_kitty
fi
