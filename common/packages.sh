#!/bin/bash

# Hello!
# To edit packages to be installed go to `settings.sh`
# These are not the droids you're looking for.

pushd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null
source 'settings.sh'

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
        apt-cache show $package 2&> /dev/null \
            && package_queue+=($package) \
        || log ERROR "Package $package not found"
    done
}

get_package_count() {
    echo "${!1}"|  sed '/^\s*$/d' | wc -l
}

guess_desktop_manager() {
    local dm=''
    local possible_dm=''

    possible_dm=$(pgrep -l "\-session" |
        sed 's/[0-9]* \([^0-9\-]*\).*/\1/' |
        awk '{print $1}'
    )
    dm=`echo ${XDG_CURRENT_DESKTOP,,}|grep -o $possible_dm ||
        echo $supported_desktop_managers|grep -o $possible_dm`

    printf "%s" "$dm"
}

pick_packages() {
    query_packages 'common_packages'
    query_packages 'graphical_packages'

    # ToDo: use `guess_desktop_manager()` and show
    #       only the relevant DM here. Or ask.
    # query_packages 'xfce_packages'
    # query_packages 'gnome_packages'
    log DEBUG "Finished package selection"
}

install_queued_packages() {
    local install_outcome=0

    if [ ${#package_queue[@]} -gt 0 ]; then
        log INFO "Installing ${#package_queue[@]} queued packages..."
        log DEBUG "Packages to install: ${package_queue[@]}"
        sudo apt-get install -y --force-yes ${package_queue[@]} 2>>setup.log &> /dev/null \
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

# Is this a real package? or is this just fantasy?
package_exists() {
    dpkg -s "$1" &> /dev/null
    return $?
}

# Test if packages exists and ask user what to install
query_packages() {
    local existing_packages=()
    local incompatible_packages=()
    local missing_packages=()
    local package_list_height=12
    local i=0

    local ammount_of_packages=$(get_package_count $1)

    log INFO "Verifying packages ($1)"
    progressbar start
    oIFS=$IFS
    IFS=$'\n'
    for line in ${!1}; do
        IFS=': ' read package description <<< $line
        if package_exists "$package"; then
            existing_packages+=("$package")
            #log DEBUG "Package exists: $package"
        else
            if verify_package_availability "$package"; then
                missing_packages+=("$package" "$description" on)
                log DEBUG "Package missing: $package"
            else
                incompatible_packages+=("$package")
                log DEBUG "Package isn't compatible: $package"
            fi
        fi
        ((i++))
        progressbar $i $ammount_of_packages "$package"
    done
    progressbar finish "      Done."

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

# Does a dry-run of every package to check if it would be installable
# Why? To do just one big `apt-get install` later.
verify_package_availability() {
    sudo apt-get install --dry-run $1 &> /dev/null
    return $?
}

