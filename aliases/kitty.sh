#!/bin/bash

# Shortcuts related to kitty terminal
# https://sw.kovidgoyal.net/kitty/


alias icat='kitty icat --align left'
alias isvg='rsvg-convert|icat'
alias kssh='kitty +kitten ssh'

# Adds autocompletion for Bash
source <(kitty + complete setup bash)
