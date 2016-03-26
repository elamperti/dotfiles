#!/bin/bash

# Change directory and list everything inside it
cs() {
    cd "$@" && ls
}

# Git checkout + pull
gkp() {
    git checkout $1 && git pull origin $1
}

# cd relative to home, because using `~/` is too much hassle
hcd() {
    cd ~/$1
}

# Make directory and enter immediately
mkd() {
    [ -n "$*" ] && mkdir -p "$@" && cd "$@"
}

# Function to make diffs prettier
# Taken from https://github.com/paulirish/dotfiles/blob/master/.functions
strip_diff_leading_symbols() {
    color_code_regex="(\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K])"

    # simplify the unified patch diff header
    sed -r "s/^($color_code_regex)diff --git .*$//g" | \
    sed -r "s/^($color_code_regex)index .*$/\n\1$(rule)/g" | \
    sed -r "s/^($color_code_regex)\+\+\+(.*)$/\1+++\5\n\1$(rule)\x1B\[m/g" |\

    # actually strips the leading symbols
    sed -r "s/^($color_code_regex)[\+\-]/\1 /g"
}

# Search for text within the current directory
qt() {
    grep -ir --color=always "$*" . | less -RX
    #     │└─ search all files under each directory, recursively
    #     └─ ignore case
}

# SSH breaks my terminal colors, so I reset them using this
ssh() {
    /usr/bin/ssh $@
    source ~/.bash_prompt
}

# Go up $1 directories (and eventually enter $2)
# https://stackoverflow.com/a/34090540/854076
up() {
    local p=
    local i=${1:-1}
    while (( i-- )); do
        p+="../"
    done
    cd "$p$2" && pwd
}
