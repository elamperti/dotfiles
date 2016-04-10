#!/bin/bash

pushd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null
source 'common/utils.sh'
source 'common/packages.sh'
source 'common/bundles.sh'
source 'common/logger.sh'

# Default config for bashlog
LOG_FILE=`readlink -f "$(dirname $0)/setup.log"`
LOG_LEVEL="DEBUG"
STDOUT_LOG_LEVEL="INFO"
LOG_TO_STDOUT="YES"

create_symlinks() {
    if cmd_exists "stow"; then
        [ -d ~/bin ] || mkdir ~/bin

        # stow_and_verify ~/bin bin/
        stow_and_verify ~/ shell/ 2>>setup.log \
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

main() {
    if [ "${BASH_VERSINFO}" -lt 4 ]; then
        echo "These dotfiles require Bash 4 or newer."
        exit 1
    fi

    rm setup.log # For easier debugging
    print_splash

    ask_for_sudo
    log NOTICE "Update apt package list"
    sudo apt-get update &> /dev/null ||
        log ERROR "Couldn't update apt package list"

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

    create_backup_folder

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

popd &>/dev/null
echo
