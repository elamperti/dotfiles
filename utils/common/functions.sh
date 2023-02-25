#!/bin/bash

pushd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null
source 'logger.sh'
source 'packages.sh'
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

# Checks for small details in configs
check_misc_configs() {
  if [ -n "$(grep "^NAutoVTs" /etc/systemd/logind.conf 2>/dev/null)" ]; then
    log OK "Virtual consoles are enabled"
  else
    log FAIL "Virtual consoles are currently disabled (see /etc/systemd/logind.conf)"
  fi
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
        mkdir -p "${backup_directory}"
        return $?
    fi
    return 99 # Already exists
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
    [ -v new_path ] && popd &>/dev/null
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
