#!/bin/bash

pushd "$(dirname "${BASH_SOURCE[0]}")/../../" &> /dev/null

source 'utils/common/os.sh'
guess_platform &> /dev/null || exit 1
source "utils/${DETECTED_OS}/package-actions.sh"

source 'config/package-lists.sh'

# Progressbar submodule may not be initialized yet
if [ -f 'progressbar/progressbar.sh' ]; then
  source 'progressbar/progressbar.sh'
else
  # This ugly thing over here acts as a placeholder until (hopefully)
  # PROGRESSBAR_MISSING is detected (after initializing submodules)
  progressbar() {
    return 0
  }
  PROGRESSBAR_MISSING=1
  log DEBUG "Progressbar not found"
fi

popd &> /dev/null

# This array will hold packages to be installed
package_queue=()

# Add packages to the queue safely
enqueue_packages() {
  for package in $@; do
    __package_is_available $package 2&> /dev/null \
      && package_queue+=($package) \
    || log ERROR "Package $package not found"
  done
}

get_package_count() {
  echo "${!1}"|  sed '/^\s*$/d' | wc -l
}

pick_packages() {
  query_packages 'common_packages'

  local dm=$(guess_wm)
  if [ -z "${dm}" ]; then
    log NOTICE "No desktop manager detected"
    dialog --keep-tite --title "No desktop manager detected" --yesno \
         "The setup couldn't detect a desktop manager.\nDo you want to show graphical packages anyway?" 7 54
    if [ $? -eq 0 ]; then
      query_packages 'graphical_packages'

    fi
  else
    query_packages 'graphical_packages'
    case "${dm}" in
      "xfce")
        query_packages 'xfce_packages'
        ;;
      "i3")
        query_packages 'i3_packages'
        ;;
      *)
        log WARN "Unknown desktop environment: ${dm}"
    esac
  fi
  log DEBUG "Finished package selection"
}

install_package() {
  __install_packages $1
  return $?
}

install_queued_packages() {
  local install_outcome=0

  if [ ${#package_queue[@]} -gt 0 ]; then
    log INFO "Installing ${#package_queue[@]} queued packages..."
    log DEBUG "Packages to install: ${package_queue[@]}"
    __install_packages ${package_queue[@]} \
    || install_outcome=1

    if [ $install_outcome -eq 0 ]; then
      pretty_print OK "Installed ${#package_queue[@]} required packages"
      log DEBUG "${#package_queue[@]} packages installed/present: ${package_queue[@]}"
    else
      log ERROR "There was a problem installing new packages."
      log DEBUG "Package install failed for: ${package_queue[@]}"
    fi

    # Empty queue in case this is called again
    package_queue=()
  else
    log DEBUG "No new packages installed."
  fi

  return $install_outcome
}


# Returns 0 if it's been more than a day since last update
needs_package_list_update() {
  __packages_list_needs_update
  return $?
}

# Checks if a package can be upgraded
package_has_update() {
  __package_is_stale $1
}

# Test if packages exists and ask user what to install
query_packages() {
  local existing_packages=()
  local incompatible_packages=()
  local missing_packages=()
  local package_list_height=12
  local i=0

  local ammount_of_packages=$(get_package_count $1)

  log DEBUG "Verifying packages for $1"
  log INFO "Verifying ${dialog_title[$1]}"
  progressbar start
  oIFS=$IFS
  IFS=$'\n'
  for line in ${!1}; do
    IFS=': ' read package description <<< $line
    if __package_is_installed "$package"; then
      existing_packages+=("$package")
      #log DEBUG "Package exists: $package"
    else
      if __package_is_available "$package"; then
        missing_packages+=("$package" "$description" "off")
        log DEBUG "Package missing: $package"
      else
        incompatible_packages+=("$package")
        log DEBUG "Package isn't compatible: $package"
      fi
    fi
    ((i++))
    progressbar $i $ammount_of_packages "$package"
  done
  progressbar finish "    Done."

  if [ ${#missing_packages[@]} -gt 0 ]; then
    exec 3>&1;
    selected_packages=$(dialog --keep-tite \
      --title ${dialog_title[$1]^} \
      --checklist ${dialog_desc[$1]} $(( 7 + $package_list_height )) 70 $package_list_height \
      ${missing_packages[@]} \
      2>&1 1>&3 \
    )
    exec 3>&-
    IFS=$oIFS

    enqueue_packages $selected_packages
  else
    log DEBUG "No packages to install under $1"
  fi
}

update_package_list() {
  __update_package_list
}
