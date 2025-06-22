#!/bin/bash

# i3_config_kali.sh: This will set up the i3 config for kali user and do a few other things. 
# Scenario: pimpmyi3 has finished, the VM is rebooted and logged in as root.
# This script assumes that afterPMi3 and the i3config.txt has been downloaded into 
# /home/kali/Downloads/afterPMi3/i3config.txt
# It handles the tasks at first boot as root before configuring and switching to kali user.

# Install packages.
install_apt() {
    echo "[+] Installing required tools"
    local packages=(
        zaproxy guake pcmanfm fish vim-gtk3 tmux xsel terminator cmake pkg-config
    )
    apt update && apt -y install "${packages[@]}" || true
}

# Install Vivaldi browser.
install_vivaldi() {
    echo "[+] Installing Vivaldi."
    local VIVALDI_URL="https://vivaldi.com/download/vivaldi-stable_amd64.deb"
    local VIVA="/home/kali/Downloads/vivaldi-stable_amd64.deb"

    if [[ -f "$VIVA" ]]; then
        dpkg -i $VIVA 2>/dev/null || true
        echo "Already installed or downloaded."
    else
        wget -qO $VIVA "$VIVALDI_URL"
        if [[ -f "$VIVA" ]]; then
            dpkg -i $VIVA 2>/dev/null || true
            echo "Downloaded and installed Vivaldi."
        else
            echo "Failed to download Vivaldi. Please check or try again later."
            exit 1
        fi
    fi
}

# Install VS Code.
install_vscode() {
    echo "[+] Installing Code."
    local CODE_URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    local CODE="/home/kali/Downloads/code_amd64.deb"

    if [[ -f "$CODE" ]]; then
        dpkg -i $CODE 2>/dev/null || true
        echo "VS Code already installed."
    else
        wget -qO $CODE "$CODE_URL"
        if [[ -f "$CODE" ]]; then
            dpkg -i $CODE 2>/dev/null || true
            echo "Downloaded and installed VS Code."
        else
            echo "Failed to download VS Code. Please check or try again later."
            exit 1
        fi
    fi
}

# Remove downloaded files and directories.
remove_downloads() {
    echo "[+] Removing temporary files and downloads."
    local DOWNLOADS="/home/kali/Downloads"
    rm -rf "$DOWNLOADS"/code_amd64.deb "$DOWNLOADS"/vivaldi-stable_amd64.deb "$DOWNLOADS/afterPMi3/Pictures" 2>/dev/null
}

# Main setup function.
main() {
    echo "[+] First boot as root setup for i3 Kali user."

    # Set up i3 config directory and permissions.
    mkdir -p /home/kali/.config/i3
    chown kali:kali /home/kali/.config/i3

    # Create a backup of the original config.
    cp /root/.config/i3/config /home/kali/.config/i3/config_OLD
    chown kali:kali /home/kali/.config/i3/config_OLD

    # Create symlinks for i3 utilities.
    ln -s /usr/bin/i3-alt-tab.py /home/kali/.config/i3/i3-alt-tab.py
    chown -h kali:kali /home/kali/.config/i3/i3-alt-tab.py
    ln -s /etc/i3status.conf /home/kali/.config/i3/i3status.conf
    chown -h kali:kali /home/kali/.config/i3/i3status.conf

    # Copy new config file.
    cp /home/kali/Downloads/afterPMi3/i3config.txt /home/kali/.config/i3/config
    chown kali:kali /home/kali/.config/i3/config

    # Clean up permissions for kali user.
    find /home/kali/Downloads -type d -exec chown kali:kali {} \;
    find /home/kali/Downloads -type f -exec chown kali:kali {} \;

    # Set background and pictures
    echo "[+] Setting up backgrounds."
    cd /home/kali/Downloads/afterPMi3 && \
        unzip -q Backgrounds.zip && \
        mv Backgrounds /home/kali && \
        cp i3fehbgk /usr/bin && \
        unzip -q Pictures.zip && \
        chown kali:kali Pictures && \
        find Pictures -type f -exec chown kali:kali {} \; && \
        rm -r /home/kali/Pictures
        mv Pictures /home/kali

    # Install necessary tools, applications, and clean up remaining files.
    install_apt
    install_vscode
    install_vivaldi
    remove_downloads

    echo "[+] Reboot or login as kali user to apply changes."
    echo "[+] To reboot press Alt-Shift-E, then press r."
    echo "[+] To log in press Alt-Shift-E, then press e."
    echo "[+] In the top right menu, select i3 and log in as kali."

}

main

