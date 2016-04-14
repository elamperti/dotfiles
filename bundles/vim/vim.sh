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
        send_cmd enqueue_packages "silversearcher-ag"
    fi
}

after_installs() {
    # Black magic.
    local tty=`tty`

    # Create necessary folders
    mkdir -p ~/.vim/swaps

    # Stow 2.2 has a (confirmed) bug which makes it fail for this case
    [ -d ~/.vim ] && mv ~/.vim ../../backups/vim && mkdir -p ~/.vim

    # Symlink vim folder
    ln -s "$(pwd)/vim/vimrc" ~/.vim/ \
        && send_cmd pretty_print OK "Created .vimrc symlink"

    # Install Droid Sans Mono, patched with Nerd Font
    mkdir -p ~/.local/share/fonts
    pushd ~/.local/share/fonts &>/dev/null
    if [ ! -f "Droid Sans Mono Nerd Font Complete.otf" ]; then
        curl --silent -kfLo "Droid Sans Mono Nerd Font Complete.otf" \
            "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20for%20Powerline%20Nerd%20Font%20Complete.otf"
        send_cmd log INFO "Downloaded Droid Sans Mono patched font"
    fi
    popd &>/dev/null

    curl --silent -kfLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    if [ $? ]; then
        vim +PlugInstall +qall #<$tty >$tty
    else
        send_cmd log ERROR "There was a problem installing Vim Plug"
    fi
}

# The following line is necessary.
# It allows bundles to be called without being sourced.
$@
