#!/bin/bash

# Usage:
#   backlight.sh {inc|dec} amount

# Avoid multiple instances
[ -f /tmp/brightness-lock ] && exit
touch /tmp/brightness-lock

if command -v xbacklight; then
  # xbacklight method
  xbacklight -${1} ${2}
else
  # DDC method
  cache_file='/tmp/backlight-vcp-value'
  cache_outdated() {
    min_value=$(($(date +%s) - 60 * 5 )) # minutes
    mod_time=$(date -r "${cache_file}" +%s)
    return $(($mod_time > $min_value))
  }

  # Referesh values using ddcutil if needed
  if [ ! -f "${cache_file}" ] || cache_outdated; then
    rawvcp=$(ddcutil getvcp 10)
    current_vcp_value=$(echo -n ${rawvcp}|sed -r 's/^.+current value = *([0-9]+),.+/\1/')
    max_vcp_value=$(echo -n ${rawvcp}|sed -r 's/^.+max.+ = *([0-9]+)/\1/')
  fi

  # Read values from cache when it is valid
  [ -z "$current_vcp_value" ] && read current_vcp_value max_vcp_value <<< $(cat "${cache_file}")

  # Calc new brightness
  [ "${1}" == 'inc' ] && op='+' || op='-'
  new_brightness=$((${current_vcp_value} $op ${2}))

  # Check boundaries
  if [[ "$new_brightness" -gt "$max_vcp_value" ]]; then
    new_brightness="${max_vcp_value}"
  elif [[ "$new_brightness" -lt 0 ]]; then
    new_brightness=0
  fi

  # Save values to cache
  echo "${new_brightness} ${max_vcp_value}" >$cache_file

  # Send new value to display
  ddcutil setvcp 10 ${new_brightness} --nodetect -d 1
  ddcutil setvcp 10 ${new_brightness} --nodetect -d 2
fi

# Unlock
rm /tmp/brightness-lock
