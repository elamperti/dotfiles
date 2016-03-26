#!/bin/bash

# Helper constants for questions
DEFAULT_YES="Y"
DEFAULT_NO="N"

# For questions asked using `$DEFAULT_YES`
answer_was_no() {
    [[ "$REPLY" =~ ^[Nn]$ ]] \
        && return 0 \
        || return 1
}

# For questions asked using `$DEFAULT_NO`
answer_was_yes() {
    [[ "$REPLY" =~ ^[Yy]$ ]] \
        && return 0 \
        || return 1
}

#
# ask_yes_no
#
# Parameters:
#   * prompt (string)
#   * [default_option] (string): either `$DEFAULT_YES` or `$DEFAULT_NO`
#
ask_yes_no() {
    local possible_options="y/n"
    if [ $2 == $DEFAULT_YES ]; then
        possible_options="Y/n"
    elif [ $2 == $DEFAULT_NO ]; then
        possible_options="y/N"
    fi

    read -p "${fg_yellow}$1 [$possible_options] ${normal}" -n1 -e
    echo
}
