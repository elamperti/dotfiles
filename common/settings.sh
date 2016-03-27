#!/bin/bash

common_packages="
    bash-completion: command completion for Bash
    build-essential: packages required to compile C programs
    curl: tool to transfer data using several protocols
    dnsutils: contains dig, nslookup and other tools
    git: popular distributed version control system
    htop: interactive process viewer
    mc: Midnight Commander file manager
    mtr: network diagnostic tool
    ssh: OpenSSH client
    tmux: terminal multiplexer (similar to \`screen\`)
    dropbear: alternative SSH server
"

graphical_packages="
    filezilla: FTP client
    gdebi: simple tool to install \`.deb\` files
    gnome-terminal: Gnome terminal emulator
    guake: quake-inspired dropdown terminal
    xclip: command line interface for clipboard
    vlc: media player
"

xfce_packages="
    pavucontrol: a volume control for the Pulse audio server
    xfce4-whiskermenu-plugin: better Start menu (with search)
"

gnome_packages=""

declare -A dialog_title
declare -A dialog_desc

dialog_title[common_packages]="common packages"
dialog_desc[common_packages]="Packages used from terminal and usually found across different distributions."

dialog_title[graphical_packages]="graphical packages"
dialog_desc[graphical_packages]="Programs that require a window manager to be used or are only useful in that context."

dialog_title[xfce_packages]="XFCE packages"
dialog_desc[xfce_packages]=""

dialog_title[gnome_packages]="Gnome packages"
dialog_desc[gnome_packages]=""

supported_desktop_managers=("xfce" "gnome")
