#!/bin/bash
# SSL CERTIFICATE MONITOR
# Description: Checks certs of given domains and warns near expiration date
keep_in_cache 240 && return

# defaults
domains=("elamperti.com openscrobbler.com")
warnDaysBefore=14
useNerdFonts=no

# Load variables
source "$HOME/dotfiles/utils/common/richtext.sh"
get_motd_config

# Initialize icons
if [[ "${useNerdFonts}" == "yes" ]]; then
  statusGood="﫟"
  statusBad=""
  statusUnknown=""
  statusWarning=""
else
  statusGood="●"
  statusBad="${bold}x"
  statusUnknown="?"
  statusWarning="!"
fi

if ! command -v "openssl" &>/dev/null; then
  echo -e "Please install ${fg_white}${bold}openssl${normal} to check the expiration dates of SSL certificates."
else
  currentTime=$(date +%s)
  for domain in $domains; do
      certTime=$(openssl s_client -connect ${domain}:443 < /dev/null 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)

      if [ -n "$certTime" ]; then
        certLineTime="valid until $(date -d "${certTime}" +"%d %b %Y")"
        certDate="$(date -d "${certTime}" +%s)"
        if [ "${certDate}" -ge "${currentTime}" ]; then
            diffInDays=$(( (certDate - currentTime) / 60 / 60 / 24 ))
            if [ ${diffInDays} -le $warnDaysBefore ]; then
              icon="${blink}${fg_yellow}${statusWarning}${normal} "
            else
              icon="${fg_green}${statusGood}${normal}"
            fi
        else
            icon="${fg_red}${statusBad}"
        fi
      else
        certLineTime="${dim}No data available${normal}"
        icon="${fg_gray}${statusUnknown}${normal} "
      fi

      printf "  ${icon} %-30s${certLineTime}\n" "${domain}"
  done
fi

