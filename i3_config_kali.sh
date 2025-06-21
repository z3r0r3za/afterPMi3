#!/bin/bash

# Set up i3 config for kali user. pimpmyi3 has finished.
# You rebooted and logged in as root for the first time.
# Assumes you have downloaded this repo to Downloads directory: 
# /home/kali/downloads/afterPMi3/i3_config_kali.sh.
# After i3 config is ready and these items are installed, logout like this:
# Press Alt-Shift-E, e to logout. Select i3 from the top right menu 
# and log in as kali user. Then run the final script to finish the set up.

install_apt() {
    # Some of these might have been installed already, but keeping them here anywway.
    echo "[+] Installing zaproxy guake pcmanfm fish vim-gtk3 tmux xsel terminator cmake pkg-config"
    packages=(zaproxy guake pcmanfm fish vim-gtk3 tmux xsel terminator cmake pkg-config)
    apt update && apt -y install "${packages[@]}"
}

install_vivaldi() {
    echo "[+] Installing Vivaldi"
    wget -q "https://vivaldi.com/download/vivaldi-stable_amd64.deb" -O /home/kali/Downloads/vivaldi-stable_amd64.deb
    #VIVA="vivaldi-stable_amd64.deb"
    #if [ -f "$VIVA" ]; then
    dpkg -i /home/kali/Downloads/vivaldi-stable_amd64.deb
    #fi
}

install_vscode() {
    echo "[+] Installing Code"
    wget -q "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -O /home/kali/Downloads/code_amd64.deb
    CODE="code_amd64.deb"
    if [ -f "$CODE" ]; then
        dpkg -i /home/kali/Downloads/code_amd64.deb
    fi    
}

remove_downloads() {
    echo "[+] Removing downloaded deb files"
    rm -f /home/kali/Downloads/code_amd64.deb
    rm -f /home/kali/Downloads/vivaldi-stable_amd64.deb
    rm -rf /home/kali/Downloads/afterPMi3/Pictures
}

# Create and cd to directory.
find /home/kali/Downloads/. -type d -exec chown kali:kali {} \;
find /home/kali/Downloads/. -type f -exec chown kali:kali {} \;
echo "[+] Set up i3 config for kali user."
mkdir /home/kali/.config/i3
chown kali:kali /home/kali/.config/i3
cd /home/kali/.config/i3 || exit
# Copy backup of original config to check in case it was updated.
cp /root/.config/i3/config /home/kali/.config/i3/config_OLD
chown kali:kali /home/kali/.config/i3/config_OLD
# Create symlinks and change permissions.
ln -s /usr/bin/i3-alt-tab.py i3-alt-tab.py
chown -h kali:kali i3-alt-tab.py
ln -s /etc/i3status.conf i3status.conf
chown -h kali:kali i3status.conf
# Copy new config to kali user.
cp /home/kali/Downloads/afterPMi3/i3config.txt /home/kali/.config/i3/config
chown kali:kali /home/kali/.config/i3/config

echo "[+] Set up backgrounds and feh as background switcher."
cd /home/kali/Downloads/afterPMi3
unzip -q Backgrounds.zip
chown kali:kali Backgrounds
find Backgrounds -type f -exec chown kali:kali {} \;
mv Backgrounds /home/kali/
cp i3fehbgk /usr/bin
unzip -q Pictures.zip
chown kali:kali Pictures
find Pictures -type f -exec chown kali:kali {} \;
cp -a Pictures/. /home/kali/Pictures

install_vivaldi
# Uncomment this if vscode isn't installed
#install_vscode
install_apt
remove_downloads
