#!/bin/bash

get_name() { echo "Dark mode"; }
get_desc() { echo "Switch light/dark themes automatically"; }

pushd ".." &>/dev/null
source "bundle-tools.sh"
popd &>/dev/null

verify_requirements() {
  return
}

on_init() {
    send_cmd enqueue_packages "darkman"
}

after_installs() {
  send_cmd log INFO "Enabling darkman service..."
  systemctl --user enable --now darkman.service
}

# The following line is necessary.
# It allows bundles to be called without being sourced.
$@
