#!/bin/bash

# Colorize things
alias dir='dir --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias ls='ls --color=auto'

# Other useful aliases
alias :q='exit'
alias df='df -h'
alias du='du -h'
alias la='ls -Ah'
alias ll='ls -lh'
alias map='xargs -n1'
alias s='cd ..'
alias sl='ls'

# Short utilities
alias cc='xclip -selection clip'
alias tk='pkill'

alias nano='vim'

alias e='vim'
alias o='xdg-open'
alias q='exit'

# apt shortcuts
alias sapi='sudo apt-get install'
alias sapr='sudo apt-get remove'
alias saps='sudo apt-cache search'
alias sapu='sudo apt-get update'

# Git shortcut madness
alias g='git'
alias ga='git add'
alias gaa='git add -A'
alias gac='git commit -a -m'
alias gap='git add --patch'
alias gb='git branch -v'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gfa='git fetch --all'
alias gk='git checkout'
alias gl='git log'
alias gm='git merge'
alias gmt='git mergetool'
alias gmv='git mv'
alias gol='git log --oneline'
alias gpl='git pull'
alias gplom='git pull origin master'
alias gps='git push'
alias gpsom='git push origin master'
alias grb='git rebase'
alias grm='git rm --cached'
alias grs='git reset'
alias gs='git status' # -sb
alias gsa='git stash apply'
alias gsh='git stash save'
alias gsl='git stash list'
alias gsp='git stash pop'
