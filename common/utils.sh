#!/bin/bash

pushd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null
source 'logger.sh'
source 'questions.sh'
source 'richtext.sh'
popd &> /dev/null

ask_for_sudo() {
    log DEBUG "Ask for the administrator password"
    sudo -p "  Please enter password for $USER: " -v &> /dev/null

    # Verify if privileges were granted
    if [[ ! $(sudo -n echo 1) ]]; then
        clear_last_line # sudo: a password is required
        log ERROR "Couldn't get sudo privileges. Aborting."
        exit 1
    fi

    # Update existing `sudo` timestamp until this script has finished
    # https://gist.github.com/cowboy/3118588
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done &> /dev/null &
}

cmd_exists() {
    command -v "$1" &> /dev/null
    return $?
}

# Taken from here: https://stackoverflow.com/a/27326630/854076
clear_last_line() {
    tput cuu 1 && tput el
}

create_backup_directory() {
    local backup_directory="$(dirname "${BASH_SOURCE[0]}")/../backups/"
    if [ ! -d "${backup_directory}" ]; then
        mkdir -p "${backup_directory}" && return 0
    fi
    return 1 # Already exists or error creating
}

# Returns the current OS or Linux distribution
# Defaults to `unknown`
guess_platform() {
  if type -p lsb_release >/dev/null 2>&1; then
    case "$(lsb_release -si)" in
      "archlinux"|"Arch Linux"|"arch"|"Arch"|"archarm"|"ManjaroLinux")
        echo "arch"
        return
        ;;
      "Debian"|"Ubuntu")
        echo "debian"
        return
        ;;
    esac
  fi
  echo "unknown"
  return 1
}

# Returns a compatible window manager name or empty
guess_wm() {
    local wm=''
    local possible_wm=''

    possible_wm=$(pgrep -l "\-session" |
        sed 's/[0-9]* \([^0-9\-]*\).*/\1/' |
        awk '{print $1}'
    )
    log DEBUG "Possible WM: ${possible_wm}"

    if [ -n "${possible_wm}" ]; then
        wm=$(echo ${XDG_CURRENT_DESKTOP,,}|grep -o "$possible_wm" ||
             echo $supported_desktop_managers|grep -o "$possible_wm")
    fi

    echo "${wm}"
}

install_package() {
    sudo apt-get -qqy install $@ > /dev/null
    return $?
}

# Returns 0 if it's been more than a day since last apt update
needs_package_list_update() {
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

# Checks if a package can be upgraded; works best if used after apt-get update
package_has_update() {
    [ -n "$(sudo apt-get upgrade --just-print|grep 'Inst ${1,,} ')" ]
    return $?
}

# I was born in MS-DOS.
pause() {
    echo
    read -n1 -s -p "Press any key to continue..."
    echo -e "\n"
}

stow_and_verify() {
    local backups_folder=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/../backups")
    local dest_path="${1%/}"
    local target_path="${2%/}"

    # if target path is a directory, go into it and reset it
    if [[ ${2%/} == *"/"* ]]; then
        local new_path=${target_path%/*}
        local target_name=${target_path##*/}
        pushd "${new_path}" &>/dev/null
        target_path="${target_name}"
    fi

    # Define list of prospective files to be stowed
    if [ -d "${target_path}" ]; then
        pushd "${target_path}" &>/dev/null
        local thing_about_to_be_stowed=$(find . -mindepth 1 -type f|sed 's#^\./##')
        popd &>/dev/null
    else
        local thing_about_to_be_stowed="${target_path}"
    fi

    # If they exist, make a backup
    for prospective_file in ${thing_about_to_be_stowed}; do
        if [[ -f "${dest_path}/${prospective_file}" || -d "${dest_path}/${prospective_file}" ]]; then
            # Log first to check if it's a symlink
            if [ ! -L "${dest_path}/${prospective_file}" ]; then
                log WARN "Creating backup of ${dest_path}/${prospective_file}"
            else
                log DEBUG "Backing up symlinked file ${dest_path}/${prospective_file}"
            fi

            local backup_dest="${backups_folder}/${target_path}/${prospective_file}"
            local mv_flags="$([ -d "${dest_path}/${prospective_file}" ] && echo "-r")"

            mkdir -p "$(dirname ${backup_dest})"
            mv $mv_flags "${dest_path}/${prospective_file}" "${backup_dest}"
            if [ "$?" -ne 0 ]; then
                log ERROR "Failed to backup ${dest_path}/${prospective_file}"
                [ -v new_path ] && popd &>/dev/null
                return 1
            fi
        fi
    done

    stow -R -t "${dest_path}" "${target_path}"
    if [ $? -eq 1 ]; then
        echo -e "\nStow couldn't create the symlinks for files in ${fg_white}${target_path}${normal}"
        echo -e "You may verify the problem manually and try again."
        ask_yes_no "Try again?" $DEFAULT_YES
        if answer_was_no; then
            [ -v new_path ] && popd &>/dev/null
            return 1
        else
            echo
            # Down the rabbit hole!
            stow_and_verify $@ || ([ -v new_path ] && popd &>/dev/null; return 1)
        fi
    fi
    [ -v new_path ] && popd  &>/dev/null
    return 0
}

# Verify if a given command exists, and if it doesn't ask to install it
# Syntax: test_for "package" [OR_WARN|OR_ABORT] ["With this error message"]
test_for() {
    if ! cmd_exists "$1"; then
        echo "The ${bold}$1${normal} package is not present and it's needed to continue."
        ask_yes_no "Install $1?" $DEFAULT_YES
        if answer_was_no; then
            MESSAGE=$3

            # If setup is aborting there must be a explicit message
            if [ "$2" == "OR_ABORT" ] && [ -z "$3" ]; then
                MESSAGE="Aborting setup."
            fi

            # Print message only if it contains anyting
            [ -n "$MESSAGE" ] && echo -e "\n$MESSAGE\n"

            if [ "$2" == "OR_ABORT" ]; then
                exit 1
            else # OR_WARN
                return 1
            fi
        fi
        ask_for_sudo
        # ToDo: verify the installation succeeds or ask to try again
        install_package "$1"
        return $?
    fi
}
