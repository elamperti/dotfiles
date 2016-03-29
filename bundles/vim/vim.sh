#!/bin/bash

get_name() { echo "Vim"; }
get_desc() { echo "the editor along with plugins and .vimrc"; }

pushd ".." &>/dev/null
source "bundle-tools.sh"
popd &>/dev/null

verify_requirements() {
    if ! cmd_exists "stow"; then
        exit 1
    fi
}

on_init() {
    if ! cmd_exists "vim"; then
        send_cmd enqueue_packages "vim"
    fi
}

after_installs() {
    # Black magic.
    local tty=`tty`

    # Create necessary folders
    mkdir -p ~/.vim
    mkdir -p ~/.vim/swaps

    # Symlink vim folder
    stow_and_verify ~/.vim vim \
        && send_cmd pretty_print OK "Created .vim symlink"

    # Install Droid Sans Mono, patched with Nerd Font
    mkdir -p ~/.local/share/fonts
    pushd ~/.local/share/fonts &>/dev/null
    if [ ! -f "Droid Sans Mono Nerd Font Complete.otf" ]; then
        curl --silent -fLo "Droid Sans Mono Nerd Font Complete.otf" \
            "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20for%20Powerline%20Nerd%20Font%20Complete.otf"
        send_cmd log INFO "Downloaded Droid Sans Mono patched font"
    fi
    popd &>/dev/null

    # ToDo: transform this barbaric "remove and reinstall"
    #       into a friendly "update if already exists" :)
    rm -rf ~/.vim/plugins/Vundle.vim &> /dev/null \
        && git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/plugins/Vundle.vim &> /dev/null \
        && printf "\n" | vim +PluginInstall +qall <$tty >$tty
        #     └─ simulate the ENTER keypress for
        #        the case where there are warnings
        #         └─ ToDo: doesn't work!

    # This plugin complicates things a bit
    if cmd_exists "npm"; then
        cd ~/.vim/plugins/tern_for_vim \
            && npm install &> /dev/null
    else
        send_cmd log WARN "Couldn't install tern plugin for Vim"
    fi
}

# The following line is necessary.
# It allows bundles to be called without being sourced.
$@
