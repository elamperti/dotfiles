#!/bin/bash

pushd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null
source 'logger.sh'
source 'settings.sh'
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

    # Update existing `sudo` time stamp until this script has finished
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

function_exists() {
    declare -f -F $1 > /dev/null
    return $?
}

install_package() {
    sudo apt-get -qqy --force-yes install $@ > /dev/null
    return $?
}

# Returns the last item from all the given arguments
# Usual usage: `last_argument $@`
# https://stackoverflow.com/questions/1853946/getting-the-last-argument-passed-to-a-shell-script
last_argument() {
    echo ${@: -1}
}

# I was born in MS-DOS.
pause() {
    echo
    read -n1 -s -p "Press any key to continue..."
    echo -e "\n"
}

stow_and_verify() {
    local backup_dest=""
    local mv_flags=""
    local backups_folder="$(dirname "${BASH_SOURCE[0]}")/../backups"

    # Define list of prospective files to be stowed
    if [ -d "$2" ]; then
        thing_about_to_be_stowed=$(find $2 -mindepth 1 -type f -exec basename {} \;)
    else
        thing_about_to_be_stowed="$2"
    fi

    # If they exist, make a backup
    for prospective_file in ${thing_about_to_be_stowed}; do
        if [[ -f "$1/${prospective_file}" || -d "$1/${prospective_file}" ]]; then
            # Log first to check if it's a symlink
            if [ ! -L "$1/${prospective_file}" ]; then
                log WARN "Creating backup of $1/${prospective_file}"
            else
                log DEBUG "Backing up symlinked file $1/${prospective_file}"
            fi

            backup_dest="${backups_folder}/$2/${prospective_file}"
            mv_flags="$([ -d "$1/${prospective_file}" ] && echo "-r")"

            mkdir -p "$(dirname ${backup_dest})"
            mv $mv_flags "$1/${prospective_file}" "${backup_dest}" &>/dev/null
            if [ "$?" -ne 0 ]; then
                log ERROR "Failed to backup $1/${prospective_file}"
                return 1
            fi
        fi
    done

    stow -R -t $1 $2
    if [[ $? == 1 ]]; then
        echo -e "\nStow couldn't create the symlinks for files in ${fg_white}$(last_argument $@)${normal}"
        echo -e "You may verify the problem manually and try again."
        ask_yes_no "Try again?" $DEFAULT_YES
        if answer_was_no; then
            return 1
        else
            echo
            # Down the rabbit hole!
            stow_and_verify $@ || return 1
        fi
    fi
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
    fi
}
