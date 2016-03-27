#!/bin/bash

get_name() { echo "Git"; }
get_desc() { echo "Git, tig, diff-so-fancy and more"; }

pushd ".." &>/dev/null
source "bundle-tools.sh"
popd &>/dev/null

verify_requirements() {
    exit 0
}

on_init() {
    # You should already have git at this point, but who knows
    send_cmd enqueue_packages "git"
    send_cmd enqueue_packages "tig"

    mkdir -p ~/bin/lib/
}

after_installs() {
    #------------------------------------
    # Set user and email                |
    #------------------------------------

    local config_file=~/.gitconfig.local

    # ToDo: check if user name and email are already set

    local default_user_name=`grep -P "^$(whoami):" /etc/passwd | cut -f5 -d: | cut -f1 -d,`
    local default_user_email=""

    exec 4>&1
    user_name=$(dialog --keep-tite --title " Git configuration " --inputbox "Please enter your complete name:" 8 40 "${default_user_name}" 2>&1 1>&4)
    if [ $? -eq 0 ]; then
        user_email=$(dialog --keep-tite --title " Git configuration " --inputbox "Please enter your e-mail:" 8 40 "${default_user_email}" 2>&1 1>&4)
    fi
    exec 4>&-

    # Save user and e-mail in a local config file
    if [[ -n "${user_name}" ]]; then
        git config --file ${config_file} user.name "${user_name}"
        git config --file ${config_file} user.email "${user_email}"
    fi

    #------------------------------------
    # Download and enable diff-so-fancy |
    #------------------------------------

    # This is so close to just doing `git clone`, I feel dirty
    curl --silent -fLo ~/bin/diff-highlight "https://raw.githubusercontent.com/git/git/master/contrib/diff-highlight/diff-highlight"
    curl --silent -fLo ~/bin/diff-so-fancy "https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/diff-so-fancy"
    curl --silent -fLo ~/bin/lib/diff-so-fancy.pl "https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/lib/diff-so-fancy.pl"

    if [[ -f ~/bin/diff-highlight && -f ~/bin/diff-so-fancy ]]; then
        chmod +x ~/bin/diff-highlight
        chmod +x ~/bin/diff-so-fancy
        chmod +x ~/bin/lib/diff-so-fancy.pl

        git config --file ${config_file} pager.diff "diff-so-fancy | less --tabs=2 -RFX"
        git config --file ${config_file} pager.show "diff-so-fancy | less --tabs=2 -RFX"
    else
        send_cmd log ERROR "Failed to install diff-so-fancy"
    fi

    return
}

# The following line is necessary.
# It allows bundles to be called without being sourced.
$@
