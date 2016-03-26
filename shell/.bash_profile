#!/bin/bash

source_bash_files() {
    local file=''
    local i=''

    declare -r -a FILES_TO_SOURCE=(
        'bash_aliases'
        'bash_exports'
        'bash_functions'
        'bash_options'
        'bash_prompt'
    )

    for i in ${!FILES_TO_SOURCE[*]}; do
        file="$HOME/.${FILES_TO_SOURCE[$i]}"
        [ -r "$file" ] && source "$file"
    done
}

source_bash_files

# if [ -f /usr/local/lib/python2.7/dist-packages/powerline/bindings/bash/powerline.sh ]; then
#     source /usr/local/lib/python2.7/dist-packages/powerline/bindings/bash/powerline.sh
# fi

if [ -f $HOME/.xmodmap ]; then
    xmodmap $HOME/.xmodmap
fi

# Bash completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Unset anything that just pollutes the global space
unset -f source_bash_files

# Clear system messages (e.g.: system copyright notice, the
# date and time of the last login, the message of the day, etc.)

clear
