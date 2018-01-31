#!/usr/bin/env bats

#----------------------------------------------#
# Tests for external URLs used across the repo #
#----------------------------------------------#

setup() {
    test_url() {
        if command -v curl; then
            curl --output /dev/null --silent --head --fail "$1"
        else
            [[ $(wget -S --spider "$1" 2>&1 | grep 'HTTP/1.1 200 OK') ]]
        fi
    }
}

@test "URLs for core files" {
    test_url "https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/DejaVuSansMono/Regular/complete/DejaVu%20Sans%20Mono%20Nerd%20Font%20Complete.ttf"
}


@test "URLs for Git bundle" {
    test_url "https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy"
    test_url "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"
}

@test "URLs for Minecraft bundle" {
    test_url "http://s3.amazonaws.com/Minecraft.Download/launcher/Minecraft.jar"
    test_url "https://i.imgur.com/cNN2mo5.png"
}

@test "URLs for Steam bundle" {
    test_url "https://steamcdn-a.akamaihd.net/client/installer/steam.deb"
}

@test "URLs for Vim bundle" {
    test_url "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
}

unset -f test_url
