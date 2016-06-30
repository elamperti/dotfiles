#!/bin/bash

motd_wizard() {
    local retval=1
    pushd "$(dirname "${BASH_SOURCE[0]}")/../art/motd" &> /dev/null

    # This avoids filling a description for each item using a invisible space char here v
    artworks=($(ls *.motd|sed 's#.motd##'|awk '{a[$1]=$1}END{for(i in a)printf " "a[i]"   on "}'))

    exec 3>&1;
    local selected_motd=$(dialog --keep-tite --title 'MOTD' \
        --radiolist 'Pick a design to use as motd' 12 32 6\
        ${artworks[@]} \
        2>&1 1>&3 \
    )
    exec 3>&-

    # Return if none selected
    if [ -z "${selected_motd}" ]; then
        popd &>/dev/null
        return 1
    fi

    # Add extension back
    selected_motd="${selected_motd}.motd"

    # Shows the picked design in a dialog message
    # (replaces spaces by unicode spaces to avoid broken art)
    motd=$(cat ${selected_motd}|sed 's/ / /g')
    t_width=$(tput cols)
    t_height=$(tput lines)
    [ $t_height -ge 24 ] || t_height=24

    dialog --keep-tite --title 'Your motd' --msgbox "${motd}" \
           $(( $t_height - 12 )) $(( $t_width - 4 ))

    if [ -f /etc/motd ]; then
        cp /etc/motd "$(dirname "${BASH_SOURCE[0]}")/../backups/$(date +%Y%m%d-%H%M%S)-motd"
        log NOTICE "Backed up previous MOTD"
    fi

    sudo cp "${selected_motd}" /etc/motd
    retval=$?

    # Out of artworks folder
    popd &>/dev/null

    return $retval
}

