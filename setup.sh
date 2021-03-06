#!/bin/bash

pushd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null
source 'utils/common/functions.sh'
source 'utils/common/packages.sh'
source 'utils/common/bundles-handler.sh'
source 'utils/common/prompt-wizard.sh'
source 'utils/common/motd-wizard.sh'
source 'utils/common/aliases-picker.sh'

# Default config for bashlog
LOG_FILE=$(readlink -f "$(dirname $0)/latest.log")
LOG_LEVEL="DEBUG"
STDOUT_LOG_LEVEL="INFO"
LOG_TO_STDOUT="YES"

# To add/modify the options see `filter_args()`
print_help() {
    cat <<'EOF'

NAME
       Dotfiles setup script

OPTIONS
       -a, --aliases
           Pick aliases to be used.

       -b, --bundle BUNDLE
           Install just one particular bundle.

       -B, --bundles
           Set up bundles only.

       -h, --help
           Print this help.

       -m, --motd
           Shows the MOTD picker.

       --no-updates
           Skip updating packages even if it's needed.

       -p, --prompt
           Shows the prompt parser wizard.

       -u, --update
           Updates all the symlinks as needed.

       -v, --verbose
           Makes setup more verbose, mostly useful for debugging.

EOF
}

# See `print_help()` for a complete -and easier to read- option list
filter_args() {
    while [[ $# > 0 ]]; do
        arg="$1"

        case $arg in
            -a|--aliases)
              NO_UPDATES=1
              JUST_ALIASES=1
              ;;

            -b|--bundle)
                NO_UPDATES=1
                if [ -n "$2" ]; then
                    if bundle_exists $2; then
                        bundle_count=1
                        create_bundle_list
                        enqueue_bundle $2

                        JUST_BUNDLES=1
                        BUNDLE=$2
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
                JUST_BUNDLES=1
                ;;

            -h|--help)
                print_help
                exit 0
                ;;

            -m|--motd)
                pick_motd
                exit $?
                ;;

            --no-updates)
                NO_UPDATES=1
                ;;

            -p|--prompt)
                NO_UPDATES=1
                JUST_PROMPT=1
                ;;

            -u|--update)
                test_for "stow" OR_ABORT "Stow is needed to create symlinks."
                create_symlinks
                exit $?
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

create_symlinks() {
    if ! cmd_exists "stow"; then
        log WARN "Skipping symlink creation because stow is missing."
        return 1
    fi

    local retval=0
    log NOTICE "Updating symlinks..."

    # local function to pretty-print results
    # params: retval
    log_result_for() {
        if [ $? -eq 0 ]; then
            log OK "${1:-Done}"
        else
            log FAIL "${1:-Failed}"
            retval=1
        fi
    }

    # local function to stow and log result
    # params: friendly_name to_path from_path
    stow_and_log() {
        pretty_print INDENT RIGHT 6
        stow_and_verify "$2" "$3"
        pretty_print INDENT LEFT 6
        log_result_for "$1"
    }

    mkdir -p ~/.config

    pretty_print INDENT RIGHT 3

    # This is the actual list of things being stowed
    stow_and_log "Home directory" ~/ home/
    [ -d ~/.xkb/ ] && stow_and_log "Keyboard configuration (xkb)" ~/.xkb/ xkb/

    pretty_print INDENT LEFT 3

    test $retval -eq 0
    log_result_for #retval

    unset -f stow_and_log
    unset -f log_result_for
    return $retval
}

init_git_submodules() {
    git submodule init &>/dev/null
    if [ $? -ne 0 ]; then
        log ERROR "Failed to init submodules"
        exit 1
    fi

    git submodule update &>/dev/null && \
    log NOTICE "Submodules updated"

    if [ -v PROGRESSBAR_MISSING ]; then
        source 'utils/common/progressbar/progressbar.sh' &>/dev/null
        if [ $? -eq 0 ]; then
            log DEBUG "Progressbar was missing. Sourced submodule."
            unset PROGRESSBAR_MISSING
        fi
    fi
    # It won't check if update succeeds because setup may be run offline
}

install_custom_fonts() {
    mkdir ~/.fonts

    if [ ! -d ~/.local/share/fonts ]; then
        mkdir -p ~/.local/share
        ln -s ~/.fonts ~/.local/share/fonts
    fi

    log INFO "Adding bundled fonts..."
    pushd "$(dirname "${BASH_SOURCE[0]}")/fonts" &>/dev/null
    pretty_print INDENT RIGHT 3
    for FONT_FAMILY in *; do
      if [ -d "${FONT_FAMILY}" ]; then
        ln -s "$(pwd)/${FONT_FAMILY}" "${HOME}/.fonts/${FONT_FAMILY}" && \
        log OK "${FONT_FAMILY}"
      fi
    done
    pretty_print INDENT LEFT 3
    popd &>/dev/null

    if cmd_exists "gsettings"; then
      local font_name='DejaVu Sans Mono'
      local font_config='DejaVu Sans Mono 10'

      ask_yes_no "Set \e[1m${font_name}\e[0m as the default fixed width font?" $DEFAULT_YES
      if answer_was_yes; then
        gsettings set org.gnome.desktop.interface monospace-font-name "${font_config}"
        log NOTICE "Default fixed width font changed"
      fi
    else
        log WARN "gsettings missing, can't update default"
    fi
}

pick_motd() {
    motd_wizard
    if [ $? -eq 0 ]; then
        log OK "MOTD configured"
    else
        log WARN "MOTD art not selected"
    fi
}

pick_prompt() {
    if cmd_exists "python"; then
        log INFO "Changing Bash prompt"
        pretty_print INDENT RIGHT 3
        prompt_wizard
        if [ $? -eq 0 ]; then
            log OK "Done"
        else
            log FAIL "Failed"
        fi
        pretty_print INDENT LEFT 3
    else
        log WARN "Skipping custom Bash prompt creation"
    fi
}

print_splash() {
    clear
    echo ${fg_cyan}
    cat art/splash.asc
    echo ${normal}
}

set_keyboard_layout() {
    # My keyboard
    if cmd_exists 'setxkbmap'; then
        setxkbmap -layout 'us' -variant 'altgr-intl' -model 'pc105' -rules 'evdev' && \
        log NOTICE "Keyboard layout succesfully changed"
    else
        log WARN "Couldn't change keyboard layout (setxkbmap not found)"
    fi

    # re-apply xmodmap rules if present
    if [ -f "$HOME/.Xmodmap" ] && cmd_exists 'xmodmap'; then
        xmodmap "$HOME/.Xmodmap"
        log DEBUG "Xmodmap rules re-applied"
    fi
}

main() {
    if [ "${BASH_VERSINFO}" -lt 4 ]; then
        echo "These dotfiles require Bash 4 or newer."
        exit 1
    fi

    pretty_print INDENT RIGHT 2

    filter_args $@

    rm -f latest.log
    print_splash

    log INFO "Detected distribution: ${DETECTED_OS}"

    ask_for_sudo
    if [[ -v NO_UPDATES ]]; then
        log WARN "Skipping package list update"
    else
        if needs_package_list_update; then
            log NOTICE "Updating package list"
            update_package_list ||
                log ERROR "Couldn't update package list"
        else
            log OK "Package list already up to date"
        fi
    fi

    test_for "git" OR_ABORT
    init_git_submodules

    # Logger must be started here, would fail otherwise
    if [ -f ./common/bashlog/bashlog ]; then
        . common/bashlog/bashlog
        log INFO "Bashlog started succesfully"
    else
        log ERROR "Bashlog not found"
        exit 1
    fi

    test_for "dialog" OR_ABORT

    create_backup_directory && log INFO "Backup folder created"

    if [[ -v JUST_PROMPT ]]; then
        test_for "python" OR_ABORT
        pick_prompt
        exit
    fi

    if [[ -v JUST_ALIASES ]]; then
      log INFO "Linking aliases"
      pick_aliases
      exit
    fi

    if [[ ! -v JUST_BUNDLES ]]; then
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

        test_for "stow" OR_WARN "Keep in mind bundles may need stow."
        create_symlinks

        set_keyboard_layout

        check_misc_configs

        local window_manager=$(guess_wm)
        if [ -n "${window_manager}" ]; then
            install_custom_fonts
        else
            log WARN "Skipped installation of fonts (no WM detected)"
        fi

        if [ ! -f "$HOME/.bash_prompt" ]; then
            test_for "python" OR_WARN "Python is needed to generate a custom Bash prompt."
            pick_prompt
        fi

        pick_motd

        pick_aliases

        pick_packages
    fi

    if [[ ! -v BUNDLE ]]; then
        pick_bundles
    fi

    execute_bundle_inits
    install_queued_packages

    execute_bundle_after_installs
    install_queued_packages

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
unset -f install_custom_fonts

popd &>/dev/null
echo
