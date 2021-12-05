#!/bin/bash

get_name() { echo "Vim"; }
get_desc() { echo "the editor along with plugins and .vimrc"; }

pushd ".." &>/dev/null
source "bundle-tools.sh"
popd &>/dev/null

verify_requirements() {
  return 0
}

on_init() {
    if ! cmd_exists 'vim' || package_has_update 'vim'; then
        send_cmd enqueue_packages "vim"
    fi
    if ! cmd_exists 'ag'; then
        send_cmd enqueue_packages "silversearcher-ag"
    fi

    # This package is required to have Lua (neocomplete requires it)
    send_cmd enqueue_packages "vim-nox"

    # This package is required by deoplete
    send_cmd enqueue_packages "neovim"
}

after_installs() {
    # Black magic.
    local tty=`tty`

    # Stow 2.2 has a (confirmed) bug which makes it fail for this case
    [ -d ~/.vim ] && mv ~/.vim ../../backups/vim
    mkdir -p ~/.vim

    # Symlink vim folder
    ln -s "$(pwd)/vim/vimrc" ~/.vim/ \
        && send_cmd pretty_print OK "Created .vimrc symlink"

    # Symlink syntax folder
    mkdir -p ~/.vim/syntax
    ln -s "$(pwd)/syntax/" ~/.vim/syntax

    # Deoplete requires pynvim
    if type -p pip3 >/dev/null 2>&1; then
      pip3 install --user pynvim neovim >/dev/null
    else
      send_cmd log WARN "Python 3 is required for Deoplete"
    fi

    curl --silent -kfLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    if [ $? ]; then
        vim +PlugInstall +qall <$tty >$tty
    else
        send_cmd log ERROR "There was a problem installing Vim Plug"
    fi
}

# The following line is necessary.
# It allows bundles to be called without being sourced.
$@
