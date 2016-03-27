#!/bin/bash

RESPONSE=""
pushd "$(dirname "${BASH_SOURCE[0]}")/.." &> /dev/null
source "common/utils.sh"
popd &> /dev/null

trap on_unload EXIT

# Function to be executed on unload
on_unload() {
    echo $RESPONSE|sed "s/'/\\\'/g" >>../.tmpcommands
}

# ToDo: preserve string quotes?
send_cmd() {
    RESPONSE+="$@"
    RESPONSE+=$';\n'
}
