#!/bin/sh

TARGET_WORKSPACE=$1
APPLICATION=$2
# This could be expanded to have a third argument for the WM_CLASS

if xdotool search --limit 1 --classname "${APPLICATION}" 1>/dev/null 2>/dev/null; then
  i3-msg "workspace ${TARGET_WORKSPACE}"
else
  i3-msg "exec ${APPLICATION}; workspace ${TARGET_WORKSPACE}"
fi
