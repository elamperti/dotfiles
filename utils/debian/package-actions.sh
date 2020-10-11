#!/bin/bash

__install_packages() {
  sudo apt-get -qqy install $@ &> /dev/null
}

__package_is_available() {
  sudo apt-get install --dry-run $1 &> /dev/null
  return $?
}

__package_is_installed() {
  dpkg -s "$1" &> /dev/null
  return $?
}

__package_is_stale() {
  [ -n "$(sudo apt-get upgrade --just-print|grep 'Inst ${1,,} ')" ]
  return $?
}

__packages_list_needs_update() {
  # Return if reference file doesn't exist
  [ ! -f "/var/cache/apt/pkgcache.bin" ] && return 0

  # Get time of last apt update
  local last_update=$(stat --printf=%Y /var/cache/apt/pkgcache.bin)

  # Check if last update was more than one day ago ↴
  [ $(( $(date +%s) - ${last_update:-0} )) -lt $(( 1 * 24 * 60 * 60 )) ]

  if [[ "$?" == "1" ]]; then
    # Needs update because it was run more than a day ago
    return 1
  else
    # What about changed source lists?
    local list_changed=1

    pushd /etc/apt/ &>/dev/null
    for source_file in $(ls sources.list sources.list.d/*.list); do
      # Check if the source file was updated more recently than the last apt update
      if [ $(( $(stat --printf=%Y ${source_file}) - ${last_update:-0} )) -gt 0 ]; then
        list_changed=0
        break
      fi
    done
    popd &>/dev/null
    return ${list_changed}
  fi
}

__remove_package() {
  sudo apt-get -y remove $@
}

__update_package_list() {
  sudo apt-get update &> /dev/null
}
