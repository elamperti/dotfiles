#!/bin/bash

# Shortcuts related to kitty terminal
# https://sw.kovidgoyal.net/kitty/

if command -v "kitty" &>/dev/null; then
  alias icat='kitty icat --align left'
  alias isvg='rsvg-convert|icat'
  alias kssh='kitty +kitten ssh'

  # Adds autocompletion for Bash
  # Note: This was removed from kitty on v0.27 without warning
  # source <(kitty + complete setup bash)
fi
