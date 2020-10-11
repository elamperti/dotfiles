#!/bin/bash

guess_platform() {
  if [ -z "${DETECTED_OS}" ]; then
    if type -p lsb_release >/dev/null 2>&1; then
      case "$(lsb_release -si)" in
        "archlinux"|"Arch Linux"|"arch"|"Arch"|"archarm"|"ManjaroLinux")
          export DETECTED_OS="arch"
          ;;
        "Debian"|"Ubuntu")
          export DETECTED_OS="debian"
          ;;
      esac
    fi

    if [ -z "${DETECTED_OS}" ]; then
      # Unknown OS
      log ERROR "Unknown OS"
      exit 1
    fi
  fi
  echo "${DETECTED_OS}"
  return
}

# Returns a compatible window manager name or empty
guess_wm() {
    local wm=''
    local possible_wm=''

    # Uses wmctrl, falls back to XDG_CURRENT_DESKTOP
    possible_wm="$((wmctrl -m | grep "Name: " || echo "Name: ${XDG_CURRENT_DESKTOP}") | cut -d ' ' -f 2- | tr '[:upper:]' '[:lower:]')"

    if [[ "${possible_wm}" =~ "gnome" ]]; then
      wm="gnome"
    elif [[ "${possible_wm}" =~ "i3" ]]; then
      wm="i3"
    elif [[ "${possible_wm}" =~ "xfce" ]]; then
      wm="xfce"
    fi

    echo "${wm}"
}
