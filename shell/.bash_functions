#!/bin/bash

# Change directory and list everything inside it
cs() {
    cd "$@" && ls
}

# Extract archives - usage: extract <file>
# Taken from https://github.com/paulirish/dotfiles
function extract() {
  if [ -f "$1" ] ; then
    local filename=$(basename "$1")
    local foldername="${filename%%.*}"
    local fullpath=`perl -e 'use Cwd "abs_path";print abs_path(shift)' "$1"`
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

# Make directory and enter immediately
mkd() {
    [ -n "$*" ] && mkdir -p "$@" && cd "$@"
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

# Search for text within the current directory
qt() {
    grep -ir --color=always "$*" . | less -RX
    #     │└─ search all files under each directory, recursively
    #     └─ ignore case
}

# SSH breaks my terminal colors, so I reset them using this
ssh() {
    /usr/bin/ssh $@
    source ~/.bash_prompt
}

# Define a title for the current terminal
title() {
    echo -en "\033]0;$@\a"
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

    ws_port=${1:-8000}

    python -m SimpleHTTPServer $ws_port
}
