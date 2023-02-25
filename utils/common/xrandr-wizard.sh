#!/bin/bash

all_except() {

}

xrandr_wizard() {
    local asd=""
    local displays=()
    local primary_display=""

    displays=($(xrandr -q|grep " connected"|awk 'BEGIN{ORS=""}{print $1 " "}'))
    local display_count="${#displays[@]}"

    if [ $display_count -lt 1 ]; then
      log ERROR 'No display connected!'
    elif [ $display_count -eq 1 ]; then
      log DEBUG 'Only one display detected'
      primary_display="${displays[0]}"
    else
      exec 3>&1;
      primary_display=$(dialog --keep-tite --title "Primary display" \
          --radiolist "Pick which display to set as primary" 16 40 10\
          ${displays[@]} \
          2>&1 1>&3 \
      )
      exec 3>&-
    fi
    # pushd "$(dirname "${BASH_SOURCE[0]}")/../../art/prompt/templates/" &> /dev/null
    # popd &>/dev/null
}

xrandr_wizard
