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

holiday() {
    local countrycode=${1:-AR} # use AR by default
    gcal -n -u -q "${countrycode}" $2
}

# Make directory and enter immediately
mkd() {
    [ -n "$*" ] && mkdir -p "$@" && cd "$@"
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
