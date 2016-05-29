#!/bin/bash

DATETIME_FORMAT="+%F %T"

declare -A logger_level
logger_level[DEBUG]=10
logger_level[INFO]=20
logger_level[NOTICE]=25
logger_level[WARN]=30
logger_level[WARNING]=30
logger_level[ERR]=40
logger_level[ERROR]=40
logger_level[CRIT]=50
logger_level[CRITICAL]=50
logger_level[ALERT]=60
logger_level[EMERG]=70
logger_level[EMERGENCY]=70
# Only pretty_print() will use these values
logger_level[INDENT]=100
logger_level[TITLE]=100
logger_level[OK]=100
logger_level[FAIL]=100

logger_indentation=0

# Define this only if it wasn't defined before
if [ -z "$BASHLOG_PRESENT" ]; then
    BASHLOG_PRESENT=1 # Asume it isn't loaded
fi

if [ -z "$LOG_TO_STDOUT" ]; then
    pushd $(dirname "${BASH_SOURCE[0]}") &> /dev/null
    source 'richtext.sh'
    popd &> /dev/null
fi

log() {
    # Check for `_bashlog` only while it isn't loaded
    if [ $BASHLOG_PRESENT -eq 1 ]; then
        declare -f _bashlog &> /dev/null
        BASHLOG_PRESENT=$?
    fi

    if [[ $BASHLOG_PRESENT -eq 0 && ${logger_level[$1]} -lt 100 ]]; then
        _bashlog $1 "${@:2}"
    fi
    [ -n "$LOG_TO_STDOUT" ] && pretty_print $1 "${@:2}"
}

# Parameters: level log_message
pretty_print() {
    if [[ -z "${logger_level[$1]}" || "${logger_level[$1]}" -lt "${logger_level[${STDOUT_LOG_LEVEL:-INFO}]}" ]]; then
        return
    fi

    if [ $1 == "INDENT" ]; then
        local delta=${3:-4} # defaults to 4
        case $2 in
            "RIGHT")
                logger_indentation=$(( $logger_indentation + $delta ))
                ;;
            "LEFT")
                logger_indentation=$(( $logger_indentation - $delta ))
                ;;
            "RESET")
                # Resets to given absolute value (or zero by default)
                logger_indentation=${3:-0}
                ;;
        esac
        return
    fi

    case $1 in
        # These three levels are not meant to be used with log()
        "TITLE")
            msg_prefix="${fg_magenta}${underline}"
            ;;
        "OK")
            msg_prefix=" ${fg_green}✔${normal}  "
            ;;
        "FAIL")
            msg_prefix=" ${fg_red}✖${normal}  "
            ;;

        # Standard logging levels
        "DEBUG")
            msg_prefix="[${fg_cyan}D${normal}] "
            ;;
        "INFO")
            msg_prefix="[i] "
            ;;
        "NOTICE")
            msg_prefix="[${fg_white}i${normal}] "
            ;;
        "WARN"*)
            msg_prefix="[${fg_yellow}!${normal}]${fg_yellow} "
            ;;
        "ERR"*)
            msg_prefix=" ${fg_red}✖${normal} ${fg_red} "
            ;;
        "CRIT"*)
            msg_prefix="[${fg_red}C${normal}] "
            ;;
        "ALERT")
            msg_prefix="[${fg_red}A${normal}]${bold} "
            ;;
        "EMERG"*)
            msg_prefix="[${bold}${fg_red}E${normal}]${bold} "
            ;;

        *)
            msg_prefix="    "
            ;;
    esac

    # Indentation
    awk -v count="${logger_indentation}" 'BEGIN { while (c++ < count) printf " " }'
    # Content (prefix + text + reset format)
    echo "${msg_prefix}${@:2}${normal}"
}
