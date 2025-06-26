#!/bin/bash

# i3_config_kali.sh
# This will set up the i3 config, some other configs and install packages for the kali user.
# Install after: pimpmyi3 has finished, the VM has rebooted and logged in as root.
# This script assumes that afterPMi3 has been downloaded into: /home/kali/Downloads/afterPMi3

# Installed Packages: zaproxy, guake, pcmanfm, fish, vim-gtk3, tmux, xsel, terminator, cmake, 
# pkg-config,  vivaldi, vscode (if necessary), rustscan, feroxbuster.
# Configurations: i3, tmux, fish (and enables it), feh, various fonts, backgrounds.

# Paths for go and rust to go in zshrc/bashrc.
ZSHBASH=$(cat <<-END_TEXT
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:/usr/local/go/bin
source "$HOME/.cargo/env"
END_TEXT
)

# Install packages.
install_apt() {
    echo "[+] Installing some packages."
    local packages=(
        zaproxy guake pcmanfm hx fish vim-gtk3 tmux xsel terminator cmake pkg-config
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

# Install fonts for kali user.
install_fonts() {
    echo "[+] Installing some Nerd-fonts."
    mkdir /home/kali/Downloads/extra_fonts && chown kali:kali /home/kali/Downloads/extra_fonts
    echo "[+] Download and set up of a few more fonts."
    local URL1="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip"
    local URL2="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Monoid.zip"
    local URL3="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip"
    local TARGET="/home/kali/.local/share/fonts"
    local DESTINATION="/home/kali/Downloads/extra_fonts"

    # Download the zip files.
    wget -q "$URL1" --directory $DESTINATION || true
    wget -q "$URL2" --directory $DESTINATION || true
    wget -q "$URL3" --directory $DESTINATION || true

    if [[ ! -f "$DESTINATION/FiraCode.zip" && ! -f "$DESTINATION/Monoid.zip" && ! -f "$DESTINATION/Hack.zip" ]]; then
        echo "Failed to download ZIP files. Please check the URLs or network connection."
        exit 1
    fi

    # Set ownership.
    chown -R kali:kali $DESTINATION

    # Unzip the files to target.
    unzip -q $DESTINATION/FiraCode.zip -d $DESTINATION/FiraCode || true
    unzip -q $DESTINATION/Monoid.zip -d $DESTINATION/Monoid || true
    unzip -q $DESTINATION/Hack.zip -d $DESTINATION/Hack || true

    # Copy fonts to target directory.
    FONT_SOURCED=("$DESTINATION/FiraCode" "$DESTINATION/Monoid" "$DESTINATION/Hack")

    # Font target directory.
    FONT_DESTD="/home/kali/.local/share/fonts"
    if [ ! -d "$FONT_DESTD" ]; then
        mkdir $FONT_DESTD
        chown kali:kali $FONT_DESTD
    fi
    
    # Excluded filenames from font directory
    EXCLUDED_FILES=("LICENSE" "README.md")

    # Loop through each source directory
    for dir in "${FONT_SOURCED[@]}"; do
    find "$dir" -type f \( \
        ! -name "${EXCLUDED_FILES[0]}" -a \
        ! -name "${EXCLUDED_FILES[1]}" \
    \) -exec cp {} "$TARGET" \;
    done

    echo "[+] Installing Powerline fonts"
    cd /home/kali/Downloads
    git clone https://github.com/powerline/fonts.git
    cd fonts
    ./install.sh
    cp -r /root/.local/share/fonts/. $TARGET
    find $TARGET -type d -exec chown kali:kali {} \;
    find $TARGET/. -type f -exec chown -R kali:kali {} \;
    cd /home/kali/Downloads
    
    # Reload font cache.
    fc-cache -f /home/kali/.local/share/fonts

    # Remove font directories after they are installed.
    rm -rf $DESTINATION/{FiraCode,Monoid,Hack}
    rm -rf /home/kali/Downloads/fonts
}

install_rust_tools() {
    cargo install rustscan
    cargo install feroxbuster
}

# Remove some downloaded files and directories.
remove_downloads() {
    echo "[+] Removing some temporary files and downloads."
    local DOWNLOADS="/home/kali/Downloads"
    FILES=("$DOWNLOADS/code_amd64.deb" "$DOWNLOADS/vivaldi-stable_amd64.deb" "$DOWNLOADS/afterPMi3/Pictures")
    
    if [ -f "${FILES[0]}" ]; then
        # If the file exists, delete it
        rm -rf "${FILES[0]}"
    fi
    if [ -f "${FILES[1]}" ]; then
        # If the file exists, delete it
        rm -rf "${FILES[1]}"
    fi
    if [ -f "${FILES[2]}" ]; then
        # If the file exists, delete it
        rm -rf "${FILES[2]}"
    fi    
    #rm -rf "$DOWNLOADS"/code_amd64.deb "$DOWNLOADS"/vivaldi-stable_amd64.deb "$DOWNLOADS"/afterPMi3/Pictures 2>/dev/null
}

enable_fish() {
    # Run as root
    echo "[+] Permanently enable fish for kali user."
    chsh -s /usr/bin/fish kali
}

install_fish_config() {
    echo "[+] Set up fish config for kali user."
    cd /home/kali/Downloads/afterPMi3/
    local FISHDIR="/home/kali/.config/fish"
    local CONFDIR="/home/kali/.config"
    if [ -d "$FISHDIR" ]; then
        rm -rf $FISHDIR
        unzip -q fish.zip -d $CONFDIR || true
    fi
    if [ ! -d "$FISHDIR" ]; then
        unzip -q fish.zip -d $CONFDIR || true
    fi
}

install_ohmytmux() {
    echo "[+] Installing Oh-my-tmux"
    cd /home/kali
    git clone --single-branch https://github.com/gpakosz/.tmux.git
    chown kali:kali .tmux
    chown -R kali:kali .tmux/*
    chown -R kali:kali .tmux/.[^.]*
    ln -s -f .tmux/.tmux.conf
    chown -h kali:kali .tmux.conf
    # Commenting this line because the config already exists.
    #cp .tmux/.tmux.conf.local .
    cp /home/kali/Downloads/afterPMi3/tmux.conf.txt /home/kali/.tmux.conf.local
    chown kali:kali .tmux.conf.local
}

install_nvm() {
    echo "[+] Install nvm for kali user."
    cd /home/kali
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    #wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    cp -r /root/.nvm /home/kali/
    chown -R kali:kali .nvm/*
    chown -R kali:kali .nvm/.[^.]*
}

# Main setup function.
main() {
    echo "[+] Starting first boot as root setup for i3 kali user."

    echo "[+] Set up i3 config."
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
    cp /home/kali/Downloads/afterPMi3/config_i3.txt /home/kali/.config/i3/config
    chown kali:kali /home/kali/.config/i3/config

    echo "[+] Create some directories."
    # Add extra directories.
    mkdir -p /home/kali/tmux_buffers && chown kali:kali /home/kali/tmux_buffers
    mkdir -p /home/kali/tmux_logs && chown kali:kali /home/kali/tmux_logs
    mkdir -p /home/kali/Work && chown kali:kali /home/kali/Work
    mkdir -p /home/kali/Scripts && chown kali:kali /home/kali/Scripts
    mkdir -p /home/kali/labs && chown kali:kali /home/kali/labs
    mkdir -p /home/kali/kali && chown kali:kali /home/kali/kali

    # Set owner for kali user.
    find /home/kali/Downloads -type d -exec chown kali:kali {} \;
    find /home/kali/Downloads -type f -exec chown kali:kali {} \;

    # Set backgrounds and pictures
    echo "[+] Setting up backgrounds."
    cd /home/kali/Downloads/afterPMi3 && \
        cp i3fehbgk /usr/bin && \
        unzip -q Backgrounds.zip && \
        unzip -q Pictures.zip && \
        chown kali:kali Pictures && \
        find Pictures/. -type f -exec chown kali:kali {} \; && \
        chown kali:kali Backgrounds && \
        find Backgrounds/. -type f -exec chown kali:kali {} \;
        #rm -r /home/kali/Pictures
        # If pictures exists, just move the files.
        #mv Pictures /home/kali

    if [ ! -d "/home/kali/Backgrounds" ]; then
        mv Backgrounds /home/kali
    fi
    if [ -d "/home/kali/Pictures" ]; then
        mv Pictures /home/kali
    else
        mv Pictures/. /home/kali/Pictures
    fi

    # Install starship later if desired.
    echo "[+] Set up Starship config."
    #curl -sS https://starship.rs/install.sh -y | sh
    #curl -sS https://starship.rs/install.sh | sh
    #sh <(curl -sS https://starship.rs/install.sh) -- -y
    cp /home/kali/Downloads/afterPMi3/starship.toml /home/kali/.config
    chown kali:kali /home/kali/.config/starship.toml
        
    # Install some tools, applications, and clean up.
    install_apt
    #install_rust_tools
    #install_vscode
    install_vivaldi
    install_fonts
    remove_downloads
    install_ohmytmux
    install_fish_config
    install_nvm
    enable_fish

    # /usr/bin/vmhgfs-fuse .host:/kali /home/shared -o subtype=vmhgfs-fuse
    echo "[+] Reboot or login as kali user to apply changes."
    echo "[+] To reboot press Alt-Shift-E, then press r."
    echo "[+] To log in press Alt-Shift-E, then press e."
    echo "[+] In the top right menu, select i3 and log in as kali."
}

main
