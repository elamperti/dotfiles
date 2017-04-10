#!/bin/bash

common_packages="
    alsa-utils: utilities to control the sound card
    autoconf: configures source code packages
    autossh: starts and keeps alive a SSH connection
    aview: view images from CLI (requires imagemagick)
    bash-completion: command completion for Bash
    build-essential: packages required to compile C programs
    cmus: CLI music player with last.fm support
    curl: tool to transfer data using several protocols
    dnsutils: contains dig, nslookup and other tools
    gcal: the GNU calendar (useful to see holidays)
    git: popular distributed version control system
    htop: interactive process viewer
    httpie: CLI user-friendly HTTP client
    imagemagick: image manipulation tools
    libimage-exiftool-perl: EXIF metadata viewer (exiftool)
    mc: Midnight Commander file manager
    moreutils: sponge, vipe, pee and other utilities
    mosh: utility for intermittent SSH conections
    mtr: network diagnostic tool
    ntp: synchronize time using NTP
    ssh: OpenSSH client
    sshfs: mount directories over SSH
    tmux: terminal multiplexer (similar to \`screen\`)
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
