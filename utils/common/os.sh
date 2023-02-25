#!/bin/bash

guess_platform() {
  if [ -z "${DETECTED_OS}" ]; then
    if [ -f "/etc/arch-release" ]; then
      export DETECTED_OS="arch"
    elif type -p lsb_release >/dev/null 2>&1; then
      case "$(lsb_release -si)" in
        "archlinux"|"Arch Linux"|"arch"|"Arch"|"archarm"|"ManjaroLinux")
          # deprecate? (in favor of the check above)
          export DETECTED_OS="arch"
          ;;
        "Debian"|"Ubuntu"|"Raspbian")
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

guess_is_laptop() {
  #Linux: sudo dmidecode --string chassis-type
  #Mac:   sysctl hw.model
  return 0
}

# Returns a compatible window manager name or empty
guess_wm() {
    local wm=''
    local possible_wm=''

    # Uses wmctrl, falls back to XDG_CURRENT_DESKTOP
    if command -v "wmctrl" &>/dev/null; then
      possible_wm="$(wmctrl -m | grep "Name: ")"
    fi
    possible_wm="$(cut -d ' ' -f 2- <<<"${possible_wm:-Name: $XDG_CURRENT_DESKTOP}" | tr '[:upper:]' '[:lower:]'))"

    if [[ "${possible_wm}" =~ "gnome" ]]; then
      wm="gnome"
    elif [[ "${possible_wm}" =~ "i3" ]]; then
      wm="i3"
    elif [[ "${possible_wm}" =~ "xfce" ]]; then
      wm="xfce"
    fi

    echo "${wm}"
}
