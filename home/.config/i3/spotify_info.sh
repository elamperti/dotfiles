#!/bin/bash

IFS=$'\n'
CURRENT_SONG=($(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | egrep -A2 "artist|title"|grep -oP '(?<=string \")(?!xesam).*(?=\")'))
echo "${CURRENT_SONG[0]} - $(echo ${CURRENT_SONG[1]} | sed -E 's/ - (live (from|at|on).+|([0-9]+ )?remastered.*)$//i')"
