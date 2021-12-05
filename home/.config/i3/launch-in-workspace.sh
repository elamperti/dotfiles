#!/bin/sh
# Source: https://www.reddit.com/r/i3wm/comments/50a2fs/how_to_launch_specific_apps_when_opening_a_new/d72zkhd/

workspace=$1
shift
pgrep "^$*" && i3-msg "workspace ${workspace}" || (i3-msg "exec $*; workspace ${workspace}")
