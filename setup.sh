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

# To add/modify the options see `filter_args()`
print_help() {
    cat <<'EOF'

NAME
       Dotfiles setup script

OPTIONS
       -b, --bundle BUNDLE
           Install just one particular bundle.

        -B, --bundles
           Set up bundles only.

        -h, --help
           Print this help.

        --no-updates
           Skip `apt-get update`. Not recommended unless you already updated.

        -v, --verbose
           Makes setup more verbose, mostly useful for debugging.

EOF
}

create_symlinks() {
    if cmd_exists "stow"; then
        [ -d ~/bin ] || mkdir ~/bin

        # stow_and_verify ~/bin bin/
        stow_and_verify ~/ shell/ 2>>setup.log \
            || return 1
    else
        log WARN "Skiping symlink creation because stow is missing."
    fi
    return 0
}

# See `print_help()` for a complete -and easier to read- option list
filter_args() {
    while [[ $# > 0 ]]; do
        arg="$1"

        case $arg in
            -b|--bundle)
                if [ -n "$2" ]; then
                    if bundle_exists $2; then
                        bundle_count=1
                        enqueue_bundle $2

                        JUST_BUNDLES=1;
                        BUNDLE=$2;
                    else
                        echo "Bundle $2 not found."
                        exit 1
                    fi
                    shift
                else
                    echo -e "Missing bundle name.\n"
                    print_help
                    exit 1
                fi
                ;;

            -B|--bundles)
                JUST_BUNDLES=1;
                ;;

            -h|--help)
                print_help
                exit 0
                ;;

            --no-updates)
                NO_UPDATES=1;
                ;;

            -v|-vv|-vvv|--verbose)
                STDOUT_LOG_LEVEL="DEBUG"
                log NOTICE "Verbosity set to ${STDOUT_LOG_LEVEL}."
                ;;

            *)
                echo -e "Invalid option: $arg\n"
                print_help
                exit 1
                ;;
        esac
        shift # past argument or value
    done
}

init_git_submodules() {
    git submodule init &>/dev/null
    if [ ! $? ]; then
        log ERROR "Failed to init submodules"
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

    pretty_print INDENT RIGHT 2

    filter_args $@

    # rm setup.log
    print_splash

    ask_for_sudo
    if [[ -v NO_UPDATES ]]; then
        log WARN "Skipping apt update"
    else
        log NOTICE "Updating apt package list"
        sudo apt-get update &> /dev/null ||
                log ERROR "Couldn't update apt package list"
    fi

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

    # Create a tarball of previous backup so ./backups folder is (almost) empty
    local backup_postfix="dotfiles_backup.tar.gz"
    local backup_files_count=$(ls -l -I "*${backup_postfix}" backups/|wc -l)
    if [ ${backup_files_count} -gt 1 ]; then
        pushd backups/ >/dev/null || exit 1 # Don't take any chances!
        local backup_filename="$(date +%Y%m%d-%H%M%S)-${backup_postfix}"
        tar -zcf ${backup_filename} --exclude="*${backup_postfix}" *
        if [ $? ]; then
            find . -mindepth 1 ! -name "*${backup_postfix}" -exec rm -rf {} +
            log INFO "Backup files were stored in backups/${backup_filename}"
        else
            log ERROR "There was a problem creating a tarball of a previous backup"
            exit 1
        fi
        popd >/dev/null
    fi

    if [[ ! -v JUST_BUNDLES ]]; then
        create_backup_folder

        test_for "stow" OR_WARN "Keep in mind bundles may need stow."
        create_symlinks &&
        log NOTICE "Symlinks created"

        set_keyboard_layout

        #pick_motd
        pick_packages
    fi

    if [[ ! -v BUNDLE ]]; then
        pick_bundles
    fi

    execute_bundle_inits
    install_queued_packages

    execute_bundle_after_installs

    log DEBUG "Finished setup"
    pretty_print OK "Finished!"
}

main $@

unset -f create_symlinks
unset -f filter_args
unset -f init_git_submodules
unset -f main
unset -f print_help
unset -f print_splash

popd &>/dev/null
echo
