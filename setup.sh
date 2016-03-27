#!/bin/bash

source 'common/utils.sh'
source 'common/packages.sh'
source 'common/bundles.sh'
source 'common/logger.sh'

# Config for bashlog
LOG_FILE=`readlink -f "$(dirname $0)/setup.log"`
LOG_LEVEL="DEBUG"
LOG_TO_STDOUT="YES"

create_symlinks() {
    if cmd_exists "stow"; then
        [ -d ~/bin ] || mkdir ~/bin

        stow_and_verify -R -t ~/bin bin/ \
          && stow_and_verify -R -t ~/ shell/ \
        || return 1
    else
        echo "Skiping symlink creation because stow is missing."
    fi
    return 0
}

init_git_submodules() {
    git submodule init &>/dev/null
    if [ ! $? ]; then
        log ERROR "Failed to init submodules."
        exit 1
    fi
    git submodule update &>/dev/null
    # It won't check if update succeeds because setup may be run offline
}

print_splash() {
    clear
    echo ${fg_cyan}
    cat art/splash.asc
    echo ${normal}
}

set_keyboard_layout() {
    # My keyboard
    setxkbmap -layout 'us' -variant 'altgr-intl' -model 'pc105' -rules 'evdev'

    log NOTICE "Keyboard layout succesfully changed"
}

# Helper for create_symlinks()
stow_and_verify() {
    stow $@ 2>>setup.log
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

main() {
    if [ "${BASH_VERSINFO}" -lt 4 ]; then
        echo "These dotfiles require Bash 4 or newer."
        exit 1
    fi

    rm setup.log # For easier debugging
    print_splash

    ask_for_sudo
    log NOTICE "Update apt-get repositories"
    sudo apt-get update &> /dev/null ||
        log ERROR "Couldn't update apt repositories"

    test_for "git" OR_ABORT
    init_git_submodules
    log NOTICE "Submodules updated"

    # Logger must be started here, would fail otherwise
    if [ -f ./common/bashlog/bashlog ]; then
        . common/bashlog/bashlog
        log INFO "Bashlog started succesfully"
    else
        log ERROR "Bashlog not found"
        exit 1
    fi

    test_for "dialog" OR_ABORT

    test_for "stow" OR_WARN "Keep in mind bundles may need stow."
    create_symlinks &&
    log NOTICE "Symlinks created"

    set_keyboard_layout

    pick_packages
    pick_bundles

    execute_bundle_inits
    install_queued_packages

    execute_bundle_after_installs
    #pick_motd
    log DEBUG "Finished setup"
    pretty_print OK "Finished!"
}

main

unset -f create_symlinks
unset -f init_git_submodules
unset -f main
unset -f print_splash
unset -f stow_and_verify
echo
