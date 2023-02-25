#!/bin/bash

# Kill previous instances of powermated
prev_instances="$(pgrep -f "python .*powermated")"
if [ -n "${prev_instances}" ]; then
    # shellcheck disable=SC2086
    kill ${prev_instances}
fi

# Determine most probable user to execute powermated
prob_user=$(who|grep " :0"|head -n1|awk '{print $1}')

# Start powermated
if command -v "/usr/local/bin/powermated" &>/dev/null; then
    echo 'sleep 1 && powermated &'| su - "${prob_user:-elamperti}" -c 'at now' -s /bin/sh
fi
