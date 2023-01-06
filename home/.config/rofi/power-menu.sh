#!/usr/bin/env bash

# Icons used as options
shutdown=''
reboot=''
lock=''
suspend=''
windows=''
logout=''

# Hell is a place where you center text using spaces
TAB="             " # a 13-space long "tab", the ultimate rebellion against God
MSG="      Lock    ${TAB}Suspend  ${TAB}Logout   ${TAB}Reboot ${TAB}Windows${TAB}Shutdown"

run_rofi() {
  echo -e "$lock\n$suspend\n$logout\n$reboot\n$windows\n$shutdown" | \
  rofi -dmenu -p 'Confirmation' -mesg "${MSG}" -theme "$HOME/.config/rofi/themes/power.rasi"
}

case "$(run_rofi)" in
    "$shutdown")
        systemctl poweroff
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$lock")
        # ToDo: pause notifications
        i3lock -c 0f090c -f -i ~/.config/i3/locked-1080p.png
        ;;
    "$windows")
        notify-send "Reboot to Windows not implemented yet"
        # source ~/dotfiles/home/.bash_functions && win
        ;;
    "$suspend")
        systemctl suspend
        ;;
    "$logout")
        i3-msg exit
        ;;
esac
