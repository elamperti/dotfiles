#!/bin/bash

# Git shortcut madness
alias g='git'
alias ga='git add'
alias gaa='git add -A'
alias gac='git commit -a -m'
alias gap='git add --patch'
alias gb='git branch -v'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit -n'
alias gcp='git cherry-pick'
alias gcpc='git cherry-pick --continue'
alias gcpa='git cherry-pick --abort'
alias gd='git diff'
alias gds='git diff --staged'
alias gfa='git fetch --all'
alias gk='git checkout'
alias gkb='git checkout -b'
alias gl='git log --oneline --decorate'
alias glt='git log --oneline --decorate -10'
alias glo='git log'
alias gm='git merge'
alias gmt='git mergetool'
alias gmv='git mv'
alias gol='git log --oneline'
alias gpl='git pull'
alias gplom='git pull origin $(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null|sed "s@^origin/@@" || echo "main")'
alias gps='git push'
alias gpsoh='git push origin HEAD'
alias gpsohf='git push origin HEAD --force' # Yes, this makes sense to me
alias gpsom='git push origin $(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null|sed "s@^origin/@@" || echo "main")'
alias grb='git rebase'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias grbm='git rebase $(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null|sed "s@^origin/@@" || echo "main")'
alias grm='git rm --cached'
alias grs='git reset'
alias gs='git status' # -sb
alias gsh='git stash save'
alias gsha='git stash apply'
alias gsl='git stash list'
alias gsp='git stash pop'
alias gsw='git show'

# Git completion for shortcuts
if type __git_complete &>/dev/null; then
  __git_complete g __git_main
  __git_complete ga _git_add
  __git_complete gaa _git_add
  __git_complete gac _git_commit
  __git_complete gap _git_add
  __git_complete gb _git_branch
  __git_complete gc _git_commit
  __git_complete gca _git_commit
  __git_complete gcan _git_commit
  __git_complete gcanh _git_commit
  __git_complete gd _git_diff
  __git_complete gds _git_diff
  __git_complete gfa _git_fetch
  __git_complete gk _git_checkout
  __git_complete gkb _git_checkout
  __git_complete gkp _git_checkout
  __git_complete gl _git_log
  __git_complete glt _git_log
  __git_complete glo _git_log
  __git_complete gm _git_merge
  __git_complete gmt _git_merge
  __git_complete gmv _git_mv
  __git_complete gol _git_log
  __git_complete gpl _git_pull
  __git_complete gps _git_push
  __git_complete grb _git_rebase
  __git_complete grm _git_rm
  __git_complete grs _git_reset
  __git_complete gs _git_status
  __git_complete gsa _git_stash
  __git_complete gsh _git_stash
  __git_complete gsl _git_stash
  __git_complete gsp _git_stash
fi
