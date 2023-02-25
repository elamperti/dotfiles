#!/bin/bash

# Determine most probable user running the pulseaudio daemon
prob_user="$(ps -p "$(pgrep pulseaudio)" --format user=)"

# Set default output device
if command -v "pacmd" >/dev/null; then
    # shellcheck disable=SC2016
    echo 'sleep 4 && pacmd set-default-sink "$(pacmd list-sinks|grep "name:.*C-Media"|sed "s/.*<\(.*\)>/\1/")" >/dev/null'| su - "${prob_user:-elamperti}" -c 'at now' -s /bin/sh
fi
