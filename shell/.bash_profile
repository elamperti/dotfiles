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
        [ -r "${file}" ] && source "${file}"
        [ -r "${file}.local" ] && source "${file}.local"
    done
}

# Bash completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Git completion
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

source_bash_files

# Use marker if present
[[ -s "$HOME/.local/share/marker/marker.sh" ]] \
    && source "$HOME/.local/share/marker/marker.sh"

# fzf if present
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Include ~/bin in PATH
PATH="$PATH:$HOME/bin"

# Go binaries
if [ -d /usr/local/go/bin ]; then
  PATH="$PATH:/usr/local/go/bin"
fi

# Android paths
ANDROID_HOME="$HOME/Android/Sdk"
if [ -d "${ANDROID_HOME}" ]; then
  PATH="${PATH}:${ANDROID_HOME}/emulator"
  PATH="${PATH}:${ANDROID_HOME}/tools"
  PATH="${PATH}:${ANDROID_HOME}/tools/bin"
  PATH="${PATH}:${ANDROID_HOME}/platform-tools"
  export ANDROID_SDK_ROOT="${ANDROID_HOME}"
fi

export PATH

# CUDA binaries + libs
if [ -d /usr/local/cuda ]; then
  PATH="$PATH:/usr/local/cuda/bin"
  if [ "$(getconf LONG_BIT)" -eq 64 ]; then
    LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
  else
    LD_LIBRARY_PATH=/usr/local/cuda/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
  fi
fi

# Bind Ctrl+Left and Ctrl+Right to navigate by words easily
# This may not work everywhere, see https://stackoverflow.com/a/5029155/854076
bind '"\e[1;5C":forward-word'
bind '"\e[1;5D":backward-word'

# Unset anything that just pollutes the global space
unset -f source_bash_files

# Customized MOTD
if [ -f "$HOME/.motdrc" ]; then
  source "$HOME/.motdrc"
fi
