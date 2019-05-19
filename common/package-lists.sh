#!/bin/bash

common_packages="
    alsa-utils: utilities to control the sound card
    autoconf: configures source code packages
    autossh: starts and keeps alive a SSH connection
    aview: view images from CLI (requires imagemagick)
    bash-completion: command completion for Bash
    bind9: DNS Server
    build-essential: packages required to compile C programs
    cmus: CLI music player with last.fm support
    curl: tool to transfer data using several protocols
    dnsutils: contains dig, nslookup and other tools
    ethtool: enable Wake On LAN and more
    gcal: the GNU calendar (useful to see holidays)
    git: popular distributed version control system
    git-crypt: transparent encryption for repositories
    htop: interactive process viewer
    httpie: CLI user-friendly HTTP client
    imagemagick: image manipulation tools
    ledger: double-entry accounting system
    libimage-exiftool-perl: EXIF metadata viewer (exiftool)
    mc: Midnight Commander file manager
    moreutils: sponge, vipe, pee and other utilities
    mosh: utility for intermittent SSH conections
    mtr: network diagnostic tool
    ncdu: pretty disk space analyzer
    ntp: synchronize time using NTP
    ssh: OpenSSH client
    sshfs: mount directories over SSH
    tmux: terminal multiplexer (similar to \`screen\`)
    units: perform unit conversion from CLI
    unrar: extracts RAR files
    dropbear: alternative SSH server
"

graphical_packages="
    arduino: Arduino IDE
    bookletimposer: basic PDF document imposition
    filezilla: FTP client
    gdebi: simple tool to install \`.deb\` files
    gnome-font-viewer: Preview and install fonts
    gnome-terminal: Gnome terminal emulator
    openscad: Parametric solid 3D CAD modeller
    poedit: a gettext translations editor (i18n)
    redshift: adjusts screen color at night
    remmina: VNC and RDP client
    shutter: feature-rich screenshot tool
    tilda: a simple dropdown terminal
    vlc: media player
    wmctrl: interact with Extended Window Manager Hints
    xclip: command line interface for clipboard
"

xfce_packages="
    pavucontrol: a volume control for the Pulse audio server
    thunar-archive-plugin: enables compression/extraction within Thunar
    xfce4-genmon-plugin: add custom plugins to the panel
    xfce4-whiskermenu-plugin: better Start menu (with search)
"

i3_packages="
    arandr: graphical interface for xrandr
    lxappearance: tool to customize look and feel of your desktop
    pasystray: control the volume from the systray
"

declare -A dialog_title
declare -A dialog_desc

dialog_title[common_packages]="common packages"
dialog_desc[common_packages]="Packages used from terminal and usually found across different distributions."

dialog_title[graphical_packages]="graphical packages"
dialog_desc[graphical_packages]="Programs that require a window manager to be used or are only useful in that context."

dialog_title[xfce_packages]="XFCE packages"
dialog_desc[xfce_packages]=""

dialog_title[i3_packages]="i3 packages"
dialog_desc[i3_packages]=""

supported_desktop_managers=("xfce" "i3")
