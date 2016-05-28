#!/bin/bash

get_name() { echo "Minecraft"; }
get_desc() { echo "downloads its launcher (and Java if missing)"; }

pushd ".." &>/dev/null
source "bundle-tools.sh"
popd &>/dev/null

verify_requirements() {
    exit 0
}

on_init() {
    if ! cmd_exists "java"; then
        send_cmd enqueue_packages "openjdk-7-jre"
    fi
}

after_installs() {
    local minecraft_path="$HOME/bin/minecraft"
    local minecraft_launcher="${minecraft_path}/minecraft.jar"
    local minecraft_icon="${minecraft_path}/minecraft.png"
    local minecraft_shortcut="$HOME/Desktop/minecraft.desktop"

    # Downloads Minecraft installer if missing
    if [ ! -f ${minecraft_launcher} ]; then
        mkdir -p "${minecraft_path}" &>/dev/null
        curl --silent -kfLo "${minecraft_launcher}" \
            "http://s3.amazonaws.com/Minecraft.Download/launcher/Minecraft.jar"
        # Fail if download failed
        if [ ! $? ]; then
            exit 1
        fi
    fi

    # Make it executable
    chmod +x "${minecraft_launcher}"

    # Downloads Minecraft icon if missing
    if [ ! -f ${minecraft_icon} ]; then
        curl --silent -kfLo ${minecraft_icon} \
            "https://i.imgur.com/cNN2mo5.png"
    fi

    # Create desktop launcher
    if [ -d "$HOME/Desktop" ]; then
        cat > ${minecraft_shortcut} <<EOF
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Name=Minecraft
GenericName=Game
Exec=java -jar "${minecraft_launcher}"
Terminal=false
Icon=${minecraft_icon}
Categories=Game;
Comment=Block building game
EOF
    chmod +x "${minecraft_shortcut}"
    fi
}

# The following line is necessary.
# It allows bundles to be called without being sourced.
$@
