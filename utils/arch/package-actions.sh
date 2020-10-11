#!/bin/bash

__install_packages() {
  if command -v yay; then
    yay -S $@ # &> /dev/null
  else
    pacman -S $@ # &> /dev/null
  fi
}

__package_is_available() {
  pacman -Ss $1 &> /dev/null
  return $?
}

__package_is_installed() {
  pacman -Q "$1" &> /dev/null
  return $?
}

__package_is_stale() {
  return 1  # noop
}

__packages_list_needs_update() {
  return 1 #noop
}

__remove_package() {
  sudo pacman -Rs $@
}

__update_package_list() {
  sudo pacman -Syu
}
