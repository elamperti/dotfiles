#!/bin/bash

source_bash_files() {
    local file=''
    local i=''

    declare -r -a FILES_TO_SOURCE=(
        'bash_aliases'
        'bash_aliases.local'
        'bash_exports'
        'bash_functions'
        'bash_functions.local'
        'bash_options'
        'bash_prompt'
    )

    for i in ${!FILES_TO_SOURCE[*]}; do
        file="$HOME/.${FILES_TO_SOURCE[$i]}"
        [ -r "$file" ] && source "$file"
    done
}

source_bash_files

# Bash completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Use marker if present
[[ -s "$HOME/.local/share/marker/marker.sh" ]] \
    && source "$HOME/.local/share/marker/marker.sh"

# Unset anything that just pollutes the global space
unset -f source_bash_files
