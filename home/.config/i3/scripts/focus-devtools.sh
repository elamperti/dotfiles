#!/bin/sh

workspace=$1
DEVTOOLS_CLASSNAME="Devtools"

if xdotool search --limit 1 --classname $DEVTOOLS_CLASSNAME 1>/dev/null 2>/dev/null; then
  i3-msg "workspace ${workspace};workspace back_and_forth"
fi
