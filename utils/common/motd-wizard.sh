#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/questions.sh"

motd_wizard() {
    local exit_status=0

    pushd "$(dirname "${BASH_SOURCE[0]}")/../../art/motd" &> /dev/null

    # This avoids filling a description for each item using a invisible space char here 🡓
    artworks=($(ls *.motd|sed 's#.motd##'|awk '{a[$1]=$1}END{for(i in a)printf " "a[i]"   on "}'))

    exec 3>&1;
    local selected_motd=$(dialog --keep-tite --title 'MOTD' \
        --radiolist 'Pick a design to use as motd' 12 32 6\
        None   on \
        ${artworks[@]} \
        2>&1 1>&3 \
    )
    exec 3>&-

    # Return if none selected
    if [ -z "${selected_motd}" ] || [[ "${selected_motd}" == "None" ]]; then
        exit_status=1
    else
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

      create_local_motd_dir

      ask_yes_no "Apply MOTD art for all users?" $DEFAULT_YES
      if answer_was_no; then
          # Tries to remove previous art (if dialog is canceled it will still be there)
          find "$HOME/.config/motd/" -type l -name '00-art.motd' -delete
          ln -s "$(pwd)/${selected_motd}" "$HOME/.config/motd/00-art.motd"
      else
          # ToDo: fix relative paths
          if [ -f /etc/motd ]; then
              cp /etc/motd "../../backups/$(date +%Y%m%d-%H%M%S)-motd"
              log INFO "Backed up previous MOTD"
          fi

          sudo cp "${selected_motd}" /etc/motd

          if [ -f '/etc/update-motd.d/10-help-text' ]; then
              cp /etc/update-motd.d/10-help-text "../../backups/$(date +%Y%m%d-%H%M%S)-motd-help-text"
              sudo rm /etc/update-motd.d/10-help-text
              log INFO 'Removed original MOTD help text'
          fi
      fi
    fi

    # Out of artworks folder
    popd &>/dev/null

    pick_motd_bits
    return $exit_status
}

create_local_motd_dir() {
    mkdir -p "$HOME/.config/motd"
}

pick_motd_bits() {
    local package_list_height=12
    local motd_bits=()
    local motd_repo_path="$(dirname "${BASH_SOURCE[0]}")/../../motd"

    pushd "${motd_repo_path}" &> /dev/null

    for MOTD_FILE in *; do
        bit_description=$(head -n3 ${MOTD_FILE}|grep -Ei "# ?desc"|sed -rn 's/# ?[Dd]esc(ription)?: ?//p')
        bit_name=$(echo -n "${MOTD_FILE}"|sed -rn 's/([0-9]+\-)(.*)\..+/\2/p')

        motd_bits+=("$bit_name" "$bit_description" "off")
    done

    exec 3>&1
    selected_bits=$(dialog --keep-tite \
           --title "Dynamic bits for the MOTD" \
           --checklist "Pick bits of information and alerts to display below your MOTD art" $(( 7 + $package_list_height )) 70 $package_list_height \
           "${motd_bits[@]}" 2>&1 1>&3
    )
    dialog_retval=$?
    exec 3>&-

    if [ "${dialog_retval}" -eq 0 ]; then
        # Just in case it doesn't exist
        create_local_motd_dir

        # Clear previous bits (only symlinks), leaving art untouched
        find "$HOME/.config/motd/" -type l -not -name '00-art.motd' -delete

        for motd_bit in ${selected_bits}; do
            path_to_bit="$(find "$(pwd)" -name '*-'${motd_bit}'.*')"

            if [ $? -eq 0 ] && [ -n "${path_to_bit}" ]; then
                ln -s "${path_to_bit}" "$HOME/.config/motd/"
            else
                log ERROR "There was an error trying to reach bit «${motd_bit}»"
            fi
        done
    else
        log INFO "Canceled selection of MOTD bits."
    fi

    # Out of motd folder
    popd &>/dev/null

    return $dialog_retval
}
