#!/bin/bash

{

permissions() {
    local mod="$1"
    local path="$2"

    sudo chown root:root "$path"
    sudo chmod "$mod" "$path"
}

install_lego() {
    local path="/usr/local/bin/lego"

    curl -sSL "https://api.github.com/repos/go-acme/lego/releases/latest" \
        | jq --unbuffered -r --arg arch "$(dpkg --print-architecture)" '.assets[].browser_download_url | select(.|endswith("linux_\($arch).tar.gz"))' \
        | xargs curl -sSL \
        | sudo tar -zx -C "${path%/*}" -- "${path##*/}"

    permissions 755 "$path"
    printf "installed: %s\n" "$path"
}

install_script() {
    local name="$1"
    local path="/usr/local/bin/$name"

    sudo curl -sSL -o "$path" "https://raw.githubusercontent.com/ttuellmann/synology-letsencrypt/master/$name"

    permissions 755 "$path"
    printf "installed: %s\n" "$path"
}


install() {
    install_lego
    install_script "synology-letsencrypt.sh"
    install_script "synology-letsencrypt-reload-services.sh"
    install_script "synology-letsencrypt-make-cert-id.sh"
}

install
}
