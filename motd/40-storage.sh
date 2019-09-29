#!/bin/bash
# STORAGE METERS
# Description: Shows usage of different mountpoints
keep_in_cache 5 && return

# defaults
mountpoints=("/ Temp:/tmp")
warnWhenCapacityOver=80
showBars=yes
barWidth=50
showAll=yes
useNerdFonts=no

# Load variables
source "$HOME/dotfiles/common/richtext.sh"
get_motd_config

# Initialize styled elements
blinkingAlert=" ${blink}${bold}${fg_yellow}!${normal}"
if [[ "${useNerdFonts}" == "yes" ]]; then
  barOpening=""
  barClosing=""
  barBlock="█"
  barSpace="█"
else
  barOpening="["
  barClosing="]"
  barBlock="="
  barSpace="="
fi

for item in ${mountpoints}; do
    mountpoint="${item#*:}"
    line=$(df -hl "${mountpoint}"|tail -n1)
    usagePercent=$(echo "$line"|awk '{print $5;}'|sed 's/%//')

    if [[ "${showAll}" == "yes" ]] || [ $usagePercent -ge $warnWhenCapacityOver ]; then
      name="${item%:*}"
      usageStr="${bold}${fg_white}${name}${normal}"
      spaceAvailable=$(echo "$line"|awk '{print $4;}')

      if [[ "$showBars" == "yes" ]]; then
        usedBarWidth=$((($usagePercent*$barWidth)/100))
        usageStr="${usageStr} (${spaceAvailable} free)"
        spaceCount=9

        # Set style according to percentage used
        if [ "${usagePercent}" -ge ${warnWhenCapacityOver} ]; then
          usageBar="${fg_red}${barOpening}"
          usageStr="${usageStr}${blinkingAlert}"
          spaceCount=$(($spaceCount + 2))
        else
          usageBar="${fg_green}${barOpening}"
        fi

        # Used part of the bar
        for sep in $(seq 1 $usedBarWidth); do usageBar="${usageBar}${barBlock}"; done

        # Remaining part of the bar
        usageBar="${usageBar}${normal}${dim}"
        for sep in $(seq 1 $(($barWidth-$usedBarWidth))); do usageBar="${usageBar}${barSpace}"; done

        # Final bar
        usageBar="${usageBar}${barClosing}${normal}"

        # Add spaces to align percentage to the right
        for sep in $(seq ${spaceCount} $(($barWidth-${#name}-${#spaceAvailable}-${#usagePercent}))); do usageStr="${usageStr} "; done

        # Print status and bar
        echo -e "${usageStr} ${usagePercent}%"
        echo -e "${usageBar}\n"

      else # No bars
        usageStr="${usageStr} ${usagePercent}% (${spaceAvailable} free)"
        if [ "${usagePercent}" -ge ${warnWhenCapacityOver} ]; then
          usageStr="${usageStr}${blinkingAlert}"
        fi

        # Print status
        echo -e "  ${usageStr}"
      fi
    fi
done
