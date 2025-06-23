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

# Download, unzip, set permissions, and move these 3 fonts for kali user.
install_fonts() {
    mkdir /home/kali/Downloads/extra_fonts && chown kali:kali /home/kali/Downloads/extra_fonts
    echo "[+] Download and set up of a few more fonts."
    local URL1="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip"
    local URL2="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Monoid.zip"
    local URL3="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip"
    local TARGET="/home/kali/.local/share/fonts"
    local DESTINATION="/home/kali/Downloads/extra_fonts"

    # Download the ZIP files
    echo "[+] Downloading and checking font zip files."
    wget -q "$URL1" --directory $DESTINATION || true
    wget -q "$URL2" --directory $DESTINATION || true
    wget -q "$URL3" --directory $DESTINATION || true

    if [[ ! -f "$DESTINATION/FiraCode.zip" && ! -f "$DESTINATION/Monoid.zip" && ! -f "$DESTINATION/Hack.zip" ]]; then
        echo "Failed to download ZIP files. Please check the URLs or network connection."
        exit 1
    fi

    # Set ownership and permissions
    echo "[+] Setting permissions of downloaded zip files."
    chown -R kali:kali $DESTINATION/*
    chmod -R 755 $DESTINATION/*

    # Unzip the files to target.
    echo "[+] Unzipping files to target directory."
    unzip -q $DESTINATION/FiraCode.zip -d $DESTINATION/FiraCode || true
    unzip -q $DESTINATION/Monoid.zip -d $DESTINATION/Monoid || true
    unzip -q $DESTINATION/Hack.zip -d $DESTINATION/Hack || true

    # Copy fonts to target directory.
    echo "[+] Moving fonts to target directory."
    # Font source directories.
    FONT_SOURCED=("$DESTINATION/FiraCode" "$DESTINATION/Monoid" "$DESTINATION/Hack")

    # Font destination directory.
    #FONT_DESTD="/home/kali/.local/share/fonts"
    #mkdir -p "$DESTD"

    # Excluded filenames from font directory
    EXCLUDED_FILES=("LICENSE" "README.md")

    # Loop through each source directory
    for dir in "${FONT_SOURCED[@]}"; do
    find "$dir" -type f \( \
        ! -name "${EXCLUDED_FILES[0]}" -a \
        ! -name "${EXCLUDED_FILES[1]}" \
    \) -exec cp {} "$TARGET" \;
    done
    
    # Copy fonts to target directory.
    echo "[+] Moving fonts to target directory."
    # List of font directories to copy from.
    #declare -a source_dirs
    #source_dirs=( "$DESTINATION/FiraCode" "$DESTINATION/Monoid" "$DESTINATION/Hack" )
    #
    # Loop through each source directory
    #for dir in "${source_dirs[@]}";
    #do
    #    # List all files in the current directory, excluding LICENCE and README
    #    ls "$dir" | grep -v "LICENCE|README.md" >| $TEMP_FILES
    #
    #    # Copy the files to the target directory
    #    cp -r "$dir/" "$TARGET/".<$(date +s)
    #
    #    # Remove the temp file list after use (optional for cleanup)
    #    rm $TEMP_FILES
    #done

    echo "[+] Installing Powerline Fonts"
    cd /home/kali/Downloads
    git clone https://github.com/powerline/fonts.git
    cd fonts
    ./install.sh
    cp -r /root/.local/share/fonts/. $TARGET
    echo "[+] Setting permissions of all fonts."
    find $TARGET -type d -exec chown kali:kali {} \;
    find $TARGET/. -type f -exec chown -R kali:kali {} \;
    cd /home/kali/Downloads
    
    # Reload font cache.
    fc-cache -f /home/kali/.local/share/fonts

    # Remove font directories after they are installed.
    echo "[+] Removing font directories."
    rm -rf $DESTINATION/{FiraCode,Monoid,Hack}
    rm -rf cd /home/kali/Downloads/fonts
}

install_rust_tools() {
    cargo install rustscan
    cargo install feroxbuster
}

# Remove downloaded files and directories.
remove_downloads() {
    echo "[+] Removing temporary files and downloads."
    local DOWNLOADS="/home/kali/Downloads"
    rm -rf "$DOWNLOADS"/code_amd64.deb "$DOWNLOADS"/vivaldi-stable_amd64.deb "$DOWNLOADS/afterPMi3/Pictures" 2>/dev/null
}

enable_fish() {
    # Run as root
    echo "[+] Permanently enable fish for kali user."
    chsh -s /usr/bin/fish kali
}
    
setup_shell() {
  local KUSER="$1"
  su "$KUSER" <<'EOF'
echo "[+] Installing Oh my tmux"
cd /home/kali
git clone --single-branch https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
#cp .tmux/.tmux.conf.local .
cp /home/kali/Downloads/afterPMi3/tmux.conf.txt /home/kali/.tmux.conf.local
cd /home/kali
echo "[+] Installing ohmyfish and BobTheFish"
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish --init-command 'set argv -- --noninteractive'
fish -c "omf install bobthefish"
echo "[+] Copy new config.fish to fish"
mkdir -p /home/kali/.config/fish
cp -f fishconfig.txt /home/kali/.config/fish/config.fish
echo "[+] Reload config.fish"
source /home/kali/.config/fish/config.fish
echo "[+] Installing nvm, fisher, bass for node"
mkdir -p /home/kali/.config/fish/functions
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
fisher install edc/bass
touch /home/kali/.config/fish/functions/nvm.fish
echo "$BASS" > /home/kali/.config/fish/functions/nvm.fish
#echo "$ZSHBASH" >> /home/kali/.bashrc
#echo "$ZSHBASH" >> /home/kali/.zshrc
#echo "[+] Using chsh to make fish the permanent shell"
#echo "[+] Enter kali user's password:"
EOF
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

    # Add extra directories.
    mkdir /home/kali/tmux_buffers && chown kali:kali /home/kali/tmux_buffers
    mkdir /home/kali/tmux_logs && chown kali:kali /home/kali/tmux_logs
    mkdir /home/kali/Work && chown kali:kali /home/kali/Work
    mkdir /home/kali/Scripts && chown kali:kali /home/kali/Scripts
    mkdir /home/kali/labs && chown kali:kali /home/kali/labs
    mkdir /home/kali/kali && chown kali:kali /home/kali/kali

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

    echo "[+] Installing Starship"
    curl -sS https://starship.rs/install.sh | sh
    cp /home/kali/Downloads/afterPMi3/starship.toml /home/kali/.config
    chown kali:kali /home/kali/.config/starship.toml
        
    # Install necessary tools, applications, and clean up remaining files.
    install_apt
    install_vscode
    install_vivaldi
    install_fonts
    remove_downloads
    setup_shell "kali"
    enable_fish

    echo "[+] Reboot or login as kali user to apply changes."
    echo "[+] To reboot press Alt-Shift-E, then press r."
    echo "[+] To log in press Alt-Shift-E, then press e."
    echo "[+] In the top right menu, select i3 and log in as kali."
}

main

