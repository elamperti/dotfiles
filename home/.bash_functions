#!/bin/bash

# Plays a short notification sound
beep() {
  play -q ~/dotfiles/sounds/beep.wav &>/dev/null
}

# Change directory and list everything inside it
cs() {
    cd "$@" && ls
}

# Extract the IP address of a Docker container
dip() {
  if command -v "docker" &>/dev/null; then
    if [ -n "$1" ]; then
      docker inspect "$1" --format '{{range .NetworkSettings.Networks }}{{ .IPAddress }}{{ end }}'
      # || inspect this -> docker container ls --format "{{.ID}} {{.Image}}"|grep -i "$1"|awk '{print($1)}'
    else
      local container_ids="$(docker ps -q)"
      if [ -n "$container_ids" ]; then
        {
          echo "Image Name IP"  # Table heading
          ## And the containers' data
          echo "${container_ids}" | xargs -n 1 docker inspect --format '{{ .Config.Image }} {{ .Name }} {{range .NetworkSettings.Networks }}{{ .IPAddress }}{{ end }}' | sed 's/ \// /'
        } | column -t -s' '
      else
        echo "No running containers."
      fi
    fi
  else
    echo "Docker binary not found."
  fi
}

# Extract archives - usage: extract <file>
# Taken from https://github.com/paulirish/dotfiles
function extract() {
  if [ -f "$1" ] ; then
    local filename=$(basename "$1")
    local foldername="${filename%%.*}"
    local fullpath=$(perl -e 'use Cwd "abs_path";print abs_path(shift)' "$1")
    local didfolderexist=false
    if [ -d "$foldername" ]; then
      didfolderexist=true
      read -p "$foldername already exists, do you want to overwrite it? (y/n) " -n 1
      echo
      if [[ $REPLY =~ ^[Nn]$ ]]; then
        return
      fi
    fi
    mkdir -p "$foldername" && cd "$foldername"
    case $1 in
      *.tar.bz2) tar xjf "$fullpath" ;;
      *.tar.gz) tar xzf "$fullpath" ;;
      *.tar.xz) tar Jxvf "$fullpath" ;;
      *.tar.Z) tar xzf "$fullpath" ;;
      *.tar) tar xf "$fullpath" ;;
      *.taz) tar xzf "$fullpath" ;;
      *.tb2) tar xjf "$fullpath" ;;
      *.tbz) tar xjf "$fullpath" ;;
      *.tbz2) tar xjf "$fullpath" ;;
      *.tgz) tar xzf "$fullpath" ;;
      *.txz) tar Jxvf "$fullpath" ;;
      *.zip) unzip "$fullpath" ;;
      *) echo "'$1' cannot be extracted via extract()" && cd .. && ! $didfolderexist && rm -r "$foldername" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Git clone + cd
gcl() {
  # shellcheck disable=SC2068,SC2164
  git clone $@ && cd "$(basename "${2:-$1}" .git)"
}

# Git commit --amend --no-edit --no-verify with modified timestamp
gcanh() {
  echo "This will modify the commit's date."
  # "You can use expressions such as 'now', 'tomorrow' and specific dates/times (e.g. '7 Nov', '14:30')."
  # "Relative values can be used as well (e.g. '+1 day', '+4 hours', '2 days ago', etc.)"

  if [ -z "$1" ]; then
    read -p "New date: "

    if [ -z "${REPLY}" ]; then
      echo "No input, aborting"
      return
    fi
  else
    REPLY="$*"
  fi

  FORMATTED_DATE=$(date -R --date="${REPLY}")
  if [ "$?" -ne 0 ]; then
    echo "Unexpected date format, aborting"
    return
  fi

  export GIT_COMMITTER_DATE="${FORMATTED_DATE}"

  git commit --amend --no-edit --no-verify --date="${FORMATTED_DATE}"
  echo "Date set to ${FORMATTED_DATE}"

  unset GIT_COMMITTER_DATE
}

# Git fetch new branch + checkout
gfb() {
    git fetch origin $1:$1 && git checkout $1
}

# Git checkout + pull
gkp() {
    git checkout $1 && git pull origin $1
}

# cd relative to home, because using `~/` is too much hassle
hcd() {
    cd ~/$1
}

holidays() {
    local countrycode=${1:-AR} # use AR by default
    countrycode=${countrycode^^}
    if [[ ${countrycode} == "UK" ]]; then
      countrycode="GB_EN"
    fi

    local color_gray=$(echo -e "\e[2m")
    local color_reset=$(echo -e "\e[0m")

    # Define time period
    local months_ahead=6
    local cal_range=$(date -d "today" +%m/%Y)
    for i in $(seq 1 ${months_ahead}); do
      cal_range="${cal_range},$(date -d "today ${i} months" +%m/%Y)"
    done

    # Legal holidays only (use `-n` to include memorial days)
    gcal -N --exclude-holiday-list-title --suppress-holiday-list-separator \
      --date-format="DateBEGIN%1%D %<3#U%2: DateDayOfWeek%<3#K DateYear%>4#YDateEND" \
         --suppress-calendar --disable-highlighting \
         --cc-holidays="${countrycode}" ${cal_range} |
    sed "s/(${countrycode})//" | # Remove country code from each line
    # Format days ahead/behind
    sed 's/ *= *\(.[0-9]*\) \(days\?\)/ (\1 \2)/' |
    # Remove year and extra sign
    sed 's/ DateYear[0-9]*//' |
    # Sort items in a prettier? way
    sed 's/\(.*\) \(.\) DateBEGIN\(.*\)\: DateDayOfWeek\(...\)DateEND\(.*\)/\3: \1 [\4] \5/' |
    sed "s/\(.*\[\(Sat\|Sun\)\].*\)/${color_gray}\1${color_reset}/"
}

# Return a fragment of lorem ipsum
lipsum() {
  lipsum_text="Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
  if command -v xclip &>/dev/null; then
    echo -n ${lipsum_text}|xclip -selection clip
  else
    echo ${lipsum_text}
  fi
}

# Make directory and enter immediately
mkd() {
    [ -n "$*" ] && mkdir -p "$@" && cd "$_"
}

# Make a directory with a YYYYMMDD timestamp and enter immediately
mkt() {
  NEW_DIR="$(date "+%Y%m%d")"
  if [ -n "$*" ]; then
    NEW_DIR="${NEW_DIR} - $*"
  fi
  mkdir "${NEW_DIR}" && cd "${NEW_DIR}"
}

# Get your public IP + local one
myip() {
  local ip_local=$(ip -o route get to 1.1.1.1 | sed -n 's/.*src \([0-9.]\+\).*/\1/p')
  echo "Local IP:    ${ip_local}"

  local ip_external=$(curl --silent 'http://checkip.amazonaws.com/' 2>/dev/null)
  echo "External IP: ${ip_external:-???}"

  if command -v "nmcli" &>/dev/null; then
    IFS=% read vpn_name vpn_device < <(nmcli -t -f NAME,TYPE,DEVICE c show --active|grep ":vpn"|cut -d ':' -f1,3 --output-delimiter '%')
    if [ -n "${vpn_name}" ]; then
      echo -n "VPN:         ${vpn_name} "

echo $vpn_device
      if ifconfig "${vpn_device}"|grep -q -E '(00-){15}00'; then
        echo '(active)'
      else
        echo '(inactive)'
      fi
    fi
  fi
}

# Prints a beatiful list of recent branches of the current repository
# Arguments: [max_number_of_results [show_item_numbers]]
print_recent_branches() {
  # ToDo: implement branch selector
  # ToDo: drown this function in holy water and ask for absolution
  # ToDo: verify the console is 256-color capable
  local maxcount=${1:-10}
  local refcount=0
  local re_has_number=".*[0-9].*"
  read current_branch < <(git rev-parse --abbrev-ref HEAD)
  read my_name < <(git config --get user.name)
  read console_width < <(tput cols)

  ##########
  # Colors #
  ##########
  local bold="\e[1m"
  local color_reset="\e[0m"
  local bg="\e[48;5;"
  local fg="\e[38;5;"

  local color_branch_fg="254m"
  local color_branch_bg="27m"
  local color_timestamp_fg="111m"
  local color_author_fg="238m"
  local color_author_me="214m"
  local color_subject_fg="250m"

  echo
  while read ref; do
    if [[ "$ref" == "$current_branch" ]]; then
      continue
    else
      (( refcount++ ))
      IFS="§" read -a log_line < <(git log -n1 $ref --pretty=format:"%cr§%an§%s")
      #   [0] relative time
      #   [1] author name
      #   [2] subject (short commit description)

      local re_subject="^$ref (.*)"

      # RE to check if subject starts with $ref
      if [[ "${log_line[2]}" =~ $re_subject ]]; then
        log_line[2]="${BASH_REMATCH[1]}"

      # Check if $ref contains first word of subject
      # only if first word contains a number (issue/ticket)
      elif [[ ${log_line[2]%% *} =~ $re_has_number && "$ref" == *"${log_line[2]%% *}"* ]]; then
        log_line[2]="${log_line[2]#* }"
      fi

      # Trim log line if necessary
      local available_width=$(($console_width - ${#ref} - 6))
      if [ $available_width -gt 0 ] && [ ${#log_line[2]} -gt $available_width ]; then
        log_line[2]="${log_line[2]::$(($available_width - 1))}…"
      fi

      echo -ne "  ${fg}${color_branch_bg}${bg}${color_branch_bg}${fg}${color_branch_fg}"
      echo -ne "${bg}${color_branch_bg}${bold}${fg}${color_branch_fg}"
      echo -ne "$ref${color_reset}"
      echo -ne "${fg}${color_branch_bg}${fg}${color_subject_fg} "
      echo -ne "${log_line[2]}\n   "
      #printf "%${#ref}s" ""
      #echo -ne "  "
      echo -ne "${fg}${color_timestamp_fg}${log_line[0]}"
      echo -ne "${fg}235m - "
      echo -ne "${fg}${color_author_fg}${log_line[1]} "
      # Uncomment this to show a shiny star near your name!
      # if [[ "${log_line[1]}" == "$my_name" ]]; then
      #   echo -ne "${fg}${color_author_me} "
      # fi
      echo -ne "${color_reset}\n\n"

      [ $refcount -ge $maxcount ] && break
    fi
  done < <(git for-each-ref --sort=-committerdate --format="%(refname:short)" refs/heads/)
  echo -ne ${color_reset}
}

# Change ownership to current user
pwn() {
  sudo chown "$USER":"$USER" $@
}

# Search for text within the current directory
qt() {
    grep -ir --color=always "$*" . | less -RX
    #     │└─ search all files under each directory, recursively
    #     └─ ignore case
}

# Sets the background color to $SSH_TERM_BG when connected through SSH interactively
reset_term_bg_color() {
  if [ -n "${SSH_CONNECTION}" ] && [[ $- == *i* ]] && [ -n "${SSH_TERM_BG}" ]; then
    [ -n "${TMUX}" ] && /usr/bin/tmux select-pane -P "bg=#${SSH_TERM_BG}" || echo -e "\033]11;#${SSH_TERM_BG}\a"
  fi
}

# SSH breaks my terminal colors, so I reset them using this
# ToDo: improve this by just doing a reset of colors
ssh() {
    /usr/bin/ssh $@
    source ~/.bash_prompt
}

# Define a title for the current terminal
title() {
    echo -en "\033]0;$@\a"
}

# Overrides tmux to restore background color after using it through SSH
tmux() {
  /usr/bin/tmux -2 $@ && reset_term_bg_color
}

# Go up $1 directories (and eventually enter $2)
# https://stackoverflow.com/a/34090540/854076
up() {
    local p=
    local i=${1:-1}
    while (( i-- )); do
        p+="../"
    done
    cd "$p$2" && pwd
}

# Opens a simple HTTP server in the current folder
# Args: [ws_port=8000]
webserver() {
    if ! command -v python &>/dev/null; then
       echo "Python is not installed."
       exit 1
    fi

    local ws_port=${1:-8000}
    local py_version=$(python --version|grep -oP '(?<=Python ).')

    if [ "${py_version}" -eq 2 ]; then
      python -m SimpleHTTPServer $ws_port
    else
      python -m http.server $ws_port
    fi
}

# Reboot to Windows™
win() {
  trap 'return' SIGINT

  # Ask for sudo now, before the countdown
  sudo -v &>/dev/null

  # Countdown
  for i in {4..1}; do
    echo -ne "\rRebooting to Windows in $i seconds, press Ctrl+C to abort"

    # Wait for any key press
    read -t 1 -n 1 -s

    # If a key is pressed, skip the countdown
    if [ $? -eq 0 ]; then
        break
    fi
  done

  # Go to beginning of line and clear the line
  echo -e "\r$(tput el)"

  # Try altering the UEFI boot sequence; if not possible, change the GRUB default option
  if command -v efibootmgr &>/dev/null; then
    sudo efibootmgr -n "$(efibootmgr -v|grep -oP '(?<=Boot)[0-9]{4}(?=.+Win)')" &>/dev/null
  elif command -v grub-reboot &>/dev/null; then
    sudo grub-reboot "$(awk -F\' '/Win/ {print $2}' /boot/grub/grub.cfg)"
  else
    echo "No compatible tools were found, impossible to alter boot sequence."
    return 1
  fi

  # Reboot if the next boot is successfully pointed to Windows
  if [ $? -eq 0 ]; then
    echo "Rebooting to Windows now!"
    sleep 0.5
    reboot
  else
    echo "Error preparing for reboot, aborting."
  fi
}

alias reboot-to-windows='win'
