#!/bin/bash

pushd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null || exit 1

TIMERS_DIR="../../timers"

source 'questions.sh'


echo "systemd tweaks 🔧"
printf "‾‾‾‾‾‾‾‾‾‾‾‾‾‾\n\n"

echo "This script is for advanced users, check the source and pay close attention to warnings and errors."
printf "Things may break, tears may be shed.\n\n"


###############################################################################
# NetworkManager-wait-online.service
###############################################################################
#  This service may slow down boot and it's usually not needed.
#  By masking the service, it can be started if other requires it.

ask_yes_no "Mask NetworkManager-wait-online.service?" $DEFAULT_NO
if answer_was_yes; then
  sudo systemctl stop NetworkManager-wait-online.service
  sudo systemctl disable NetworkManager-wait-online.service
  sudo systemctl mask NetworkManager-wait-online.service
  echo "Done."
fi


###############################################################################
# Journal tweaks
###############################################################################
#  The journal may grow through time making the system feel slow

ask_yes_no "Limit journal size? (50M)" $DEFAULT_NO
if answer_was_yes; then
  sudo mkdir /etc/systemd/journald.conf.d
  sudo tee /etc/systemd/journald.conf.d/00-journal-size.conf > /dev/null <<EOT
[Journal]
SystemMaxUse=50M
EOT

  echo "Done."
fi


###############################################################################
# ntpd.service
###############################################################################
# FIXME: this is wrong
#  This service may slow down boot; if there is a reliable hw clock, it should
#  be sufficiently accurate to get things started and sync later on.
#
#  It may cause problems with programs that expect a monotonic clock.
#  Do not delay this service on a RasPi or on laptops without clock battery.

if command -v "ntpd" &>/dev/null; then
  ask_yes_no "Delay ntpd.service start?" $DEFAULT_NO
  if answer_was_yes; then
    sudo cp "${TIMERS_DIR}/system/delayed-ntpd.target" "/etc/systemd/system/"
    sudo cp "${TIMERS_DIR}/system/delayed-ntpd.timer" "/etc/systemd/system/"
    sudo systemctl daemon-reload

    sudo timedatectl set-ntp 0

    sudo systemctl stop ntpd.service
    sudo systemctl disable ntpd.service
    sudo systemctl disable ntpdate.service

    sudo systemctl enable delayed-ntpd.timer

    echo "Done."
  fi
fi


###############################################################################
# fstab format check
###############################################################################
#  If fstab has the old "nobootwait", mounts may be locking the boot sequence.

FSTAB_NOBOOTWAIT=$(grep "nobootwait" /etc/fstab)
if [ -n "$FSTAB_NOBOOTWAIT" ]; then
  echo "⚠️ Check your /etc/fstab config! 'nobootwait' is useless."
  echo "More info: https://wiki.archlinux.org/title/fstab#Automount_with_systemd"
fi
unset FSTAB_NOBOOTWAIT


# Finish
unset TIMERS_DIR
popd &>/dev/null || exit
