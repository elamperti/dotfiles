#!/bin/bash

if command -v "yay"; then
  # Makes yay update and download new packages without installing them
  # --noconfirm makes it non-interactive
  # --sudo="true" replaces any unneeded sudo request with a call to true (noop)
  yay -Syuw --noconfirm --sudo="true"

  # Launch pamac-tray to notify the user if there's any update
  # ToDo: check if pamac-tray exists,
  # ToDo: otherwise check prev cmd exit code and use notify-send
  pamac-tray &>/dev/null
else
  exit 1
fi
