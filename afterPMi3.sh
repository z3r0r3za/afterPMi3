#!/usr/bin/env bash

# afterPMi3.sh: This will set up the i3 config, some other configs and install packages for the kali user.
# Use this script: after pimpmyi3 has finished, the VM has rebooted and is logged in as root.
# This script assumes that afterPMi3 has been cloned or downloaded into: /home/kali/Downloads/afterPMi3
#
# Installed Packages: zaproxy, guake, pcmanfm, helix, fish, vim-gtk3, tmux, xsel, terminator, cmake, 
# pkg-config, vivaldi, (vs)code (if necessary), rustscan, feroxbuster, ripgrep.
#
# Configurations: i3, tmux, fish (and enables it), feh, various fonts, backgrounds.

# Paths for go and cargo copied to zshrc/bashrc.
# The back slashes prevent variables from printing values.
ZSHBASH=$(cat <<-END_TEXT
# Created by pipx on 2025-06-28 16:05:52
export PATH="\$PATH:/home/kali/.local/bin"
export PATH=\$HOME/.local/bin:\$PATH
# Paths for go and cargo.
export GOPATH=/home/kali/go
export PATH=\$PATH:\$GOPATH/bin
export PATH=\$PATH:/usr/local/go/bin
source "/home/kali/.cargo/env"
. "\$HOME/.cargo/env"
END_TEXT
)

exec > >(tee /home/kali/Downloads/afterPMi3/afterPMi3.log) 2>&1

# Ensure the script is run as root
if [[ "$EUID" -ne 0 ]]; then
    echo "[!] This script was meant to be run as root. Please switch to root and run it again."
    exit 1
fi

# Handle --help flag
if [[ "$1" == "--help" ]]; then
    cat <<EOF

Usage: ./afterPMi3.sh [--all|--none|--help]

This script configures Kali Linux for the kali user after running pimpmyi3.sh.
It installs additional tools, terminals, editors, fonts, i3 configs, and user shells.
You can choose how Rust-based tools are installed:

  --all     Install rustscan, feroxbuster, and ripgrep without prompting.
  --none    Skip installation of all Rust tools.
  (no flag) Interactive mode: ask before each Rust tool install.
  
Note: This script was written to be run directly as root, but using sudo from a non-root user with full privileges
may work. It just hasn't been tested. If it's run with sudo, a password may be required.

EOF
    exit 0
fi

# Display header and determine Rust tool install mode
# \e]8;;https://github.com/Dewalt-arch/pimpmyi3\apimpmyi3\e]8;;\a
clear
cat <<EOF

##################################################
##        afterPMi3 - Kali Setup Script         ##
##################################################

This script continues setup after running pimpmyi3.
https://github.com/Dewalt-arch/pimpmyi3

Choose your Rust tool install mode:

  [1] Install all Rust tools without prompting
  [2] Skip all Rust tool installs
  [3] Interactive prompt for each tool
  [q] Quit

EOF

while true; do
    read -p "Enter your choice [1/2/3/q]: " rust_choice
    case "$rust_choice" in
        1) CARGO_INSTALL_ALL="--all"; break ;;
        2) CARGO_INSTALL_ALL="--none"; break ;;
        3|"") CARGO_INSTALL_ALL=""; break ;;
        [Qq]) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid input. Please enter 1, 2, 3, or q to quit." ;;
    esac
done

# Set up i3 config directory and permissions.
i3_config() {
    echo "[+] Setting up i3 config for kali user."
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

    # Copy i3 new config file for kali user.
    cp /home/kali/Downloads/afterPMi3/config_i3.txt /home/kali/.config/i3/config
    chown kali:kali /home/kali/.config/i3/config

    # Copy new i3 config file for root.
    mv /root/.config/i3/config /root/.config/i3/config_OLD
    cp /home/kali/Downloads/afterPMi3/config_i3_root.txt /root/.config/i3/config
}

# Add extra directories.
create_dirs() {
    echo "[+] Create some directories."
    mkdir -p /home/kali/tmux_buffers && chown kali:kali /home/kali/tmux_buffers
    mkdir -p /home/kali/tmux_logs && chown kali:kali /home/kali/tmux_logs
    mkdir -p /home/kali/Work && chown kali:kali /home/kali/Work
    mkdir -p /home/kali/Scripts && chown kali:kali /home/kali/Scripts
    mkdir -p /home/kali/labs && chown kali:kali /home/kali/labs
    mkdir -p /home/kali/kali && chown kali:kali /home/kali/kali
}

# Set backgrounds and pictures.
setup_bg() {
    echo "[+] Setting up backgrounds."
    cd /home/kali/Downloads/afterPMi3 && \
        cp i3fehbgk /usr/bin && \
        unzip -q Backgrounds.zip && \
        cp -a Backgrounds /root && \
        unzip -q Pictures.zip && \
        chown kali:kali Pictures && \
        find Pictures/. -type f -exec chown kali:kali {} \; && \
        chown kali:kali Backgrounds && \
        find Backgrounds/. -type f -exec chown kali:kali {} \;

    if [ ! -d "/home/kali/Backgrounds" ]; then
        mv Backgrounds /home/kali
    fi
    if [ -d "/home/kali/Pictures" ]; then
        mv Pictures /home/kali
    else
        mv Pictures/. /home/kali/Pictures
    fi    
}

# Check and install packages.
install_apt() {
    echo
    echo "[+] Checking and installing some missing packages."
    local packages=(
        zaproxy guake pcmanfm hx fish tmux xsel terminator cmake pkg-config
    )
    # Array to hold packages that are not installed
    local -a to_install=()
    
    # Check which packages might exist.
    for pkg in "${packages[@]}"; do
        if ! command -v "$pkg" &> /dev/null; then
            to_install+=("$pkg")
        fi
    done
    
    # Install only the missing packages.
    if [ ${#to_install[@]} -gt 0 ]; then
        apt update && apt -y install "${to_install[@]}" || true
    else
        echo "[-] All required packages are already installed."
    fi
}

# Install Vivaldi browser if it isn't.
install_vivaldi() {
    echo
    echo "[+] Installing Vivaldi."
    local VIVALDI_URL="https://vivaldi.com/download/vivaldi-stable_amd64.deb"
    local VIVA="/home/kali/Downloads/vivaldi-stable_amd64.deb"

    # Check if vivaldi is installed.
    if command -v vivaldi >/dev/null 2>&1; then
        echo "[+] Vivaldi is already installed."
        return 0
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

# Install VS Code if it isn't.
install_vscode() {
    echo
    echo "[+] Installing VS Code."
    local CODE_URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    local CODE="/home/kali/Downloads/code_amd64.deb"

    # Check if code is installed.
    if command -v code >/dev/null 2>&1; then
        echo "[+] Code is already installed."
        return 0
    else
        wget -qO $CODE "$CODE_URL"
        if [[ -f "$CODE" ]]; then
            dpkg -i $CODE 2>/dev/null || true
            echo "[+] Downloaded and installed VS Code."
        else
            echo "[-] Failed to download VS Code. Please check or try again later."
            exit 1
        fi
    fi
}

install_rust_tools() {
    echo
    local ALL="$1"
    KALI_USER="kali"
    KALI_HOME="/home/${KALI_USER}"
    KALI_CARGO_BIN="${KALI_HOME}/.cargo/bin"
    INSTALL_ALL=false

    # Optional --all flag.
    if [[ "$ALL" == "--all" ]]; then
        INSTALL_ALL=true
        echo "[*] --all: OK, installing all 3 rust tools."
    fi

    # Prompt user to install each one if no --all option.
    ask_install() {
        local tool="$1"

        if [ "$INSTALL_ALL" = true ]; then
            return 0
        fi

        while true; do
            # Default to Y if Enter pressed.
            read -p "Continue installing $tool? [Y/n]: " yn
            yn=${yn:-Y}
            case $yn in
                [Yy]* ) return 0 ;;
                [Nn]* ) return 1 ;;
                * ) echo "y (yes) or n (no)." ;;
            esac
        done
    }

    # Function to install cargo globally using apt
    install_cargo_via_apt() {
        echo "[*] Running apt update and installing cargo."
        apt update && apt install -y cargo
    }

    if command -v cargo >/dev/null 2>&1; then
        echo "[✓] Cargo is installed: $(which cargo)"
    else
        echo "[!] 'cargo' not found in /usr/bin PATH."
        if install_cargo_via_apt; then
            echo "[+] Installed cargo with apt install."
        else
            echo "[-] Cargo isn't and wasn't installed for some reason."
            echo "[-] You'll need to install the rust tools manually."
            return 1
        fi
    fi

    # Make sure ~/.cargo/bin exists for kali user.
    sudo -u $KALI_USER mkdir -p "$KALI_CARGO_BIN"

    # Install rustscan, feroxbuster, and ripgrep only if missing.
    install_tool() {
        local rust_tool="$1"
        local install_cmd="$2"

        echo "[*] Checking if $rust_tool is already installed for $KALI_USER..."

        if sudo -u $KALI_USER "$KALI_CARGO_BIN/$rust_tool" --version >/dev/null 2>&1; then
            echo "[✓] $rust_tool is already installed. Skipping."
        else
            echo "[+] Installing $rust_tool for $KALI_USER..."
            sudo -u $KALI_USER bash -c "$install_cmd"
        fi
    }

    # Prompt to install or auto-install if --all option present.
    if ask_install "RustScan"; then
        install_tool "rustscan" "cargo install rustscan --root $KALI_HOME/.cargo"
    fi
    if ask_install "Feroxbuster"; then
        install_tool "feroxbuster" "cargo install feroxbuster --root $KALI_HOME/.cargo"
    fi
    if ask_install "Ripgrep (rg)"; then
        install_tool "rg" "cargo install ripgrep --root $KALI_HOME/.cargo"
    fi

    echo "[*] Verify installed versions:"
    for tool in rustscan feroxbuster rg; do
        if [ -x "$KALI_CARGO_BIN/$tool" ]; then
            echo -n " - $tool: "
            sudo -u $KALI_USER "$KALI_CARGO_BIN/$tool" -V
        fi
    done

    echo "[+] Copying Go and Cargo paths to bashrc/zsh."
    echo "$ZSHBASH" >> /home/kali/.bashrc
    echo "$ZSHBASH" >> /home/kali/.zshrc    
}

# Install fonts for kali user.
install_fonts() {
    echo
    echo "[+] Downloading and installing Powerline fonts, Nerd-fonts."
    mkdir /home/kali/Downloads/extra_fonts && chown kali:kali /home/kali/Downloads/extra_fonts
    echo "[+] Download and set up of a few more fonts."
    local URL1="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip"
    local URL2="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Monoid.zip"
    local URL3="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip"
    local TARGET="/home/kali/.local/share/fonts"
    local DESTINATION="/home/kali/Downloads/extra_fonts"

    # Download all the zip files in the background.
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
    echo "[+] Powerline fonts copied to kali user's home."
    
    # Reload font cache.
    fc-cache -f /home/kali/.local/share/fonts
}

# Install and set up oh-my-tmux for kali user.
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

# Set up fish config for kali user.
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
        chown -R kali:kali $FISHDIR
    fi
}

# Install and setup starfish for kali user.
install_starship() {
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    echo "[+] Set up Starship config."
    cp /home/kali/Downloads/afterPMi3/starship.toml /home/kali/.config
    chown kali:kali /home/kali/.config/starship.toml   
}

# Install nvm for kali user.
install_nvm() {
    echo "[+] Install nvm for kali user."
    cd /home/kali
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    cp -r /root/.nvm /home/kali/
    chown -R kali:kali .nvm/*
    chown -R kali:kali .nvm/.[^.]*
}

enable_fish() {
    # Run as root
    echo "[+] Permanently enable fish for kali user."
    chsh -s /usr/bin/fish kali
}

# Remove some downloaded files and directories.
remove_downloads() {
    echo
    echo "[+] Removing some downloaded files."
    local NERDFONTS="/home/kali/Downloads/extra_fonts"
    local DOWNLOADS="/home/kali/Downloads"
    
    FILES=(
        "$DOWNLOADS/code_amd64.deb" 
        "$DOWNLOADS/vivaldi-stable_amd64.deb" 
        "$DOWNLOADS/afterPMi3/Pictures"
        "$DOWNLOADS/fonts"
    )
    
    for file in "${FILES[@]}"; do
        if [ -f "$file" ]; then
            rm -rf "$file" 2>/dev/null
        elif [ -d "$file" ]; then
            rm -rf "$file" 2>/dev/null
        fi
    done    
    
    # Remove other nerd-font directories after they are installed.
    rm -rf $NERDFONTS/{FiraCode,Monoid,Hack}

    # Confirm ownership of remaining Downloads for kali user.
    find /home/kali/Downloads -type d -exec chown kali:kali {} \;
    find /home/kali/Downloads -type f -exec chown kali:kali {} \;

    #if [ -f "${FILES[0]}" ]; then
    #    # If the file exists, delete it
    #    rm -rf "${FILES[0]}"
    #fi
    #if [ -f "${FILES[1]}" ]; then
    #    # If the file exists, delete it
    #    rm -rf "${FILES[1]}"
    #fi
    #if [ -d "${FILES[2]}" ]; then
    #    # If the file exists, delete it
    #    rm -rf "${FILES[2]}"
    #fi    
    #rm -rf "$DOWNLOADS"/code_amd64.deb "$DOWNLOADS"/vivaldi-stable_amd64.deb "$DOWNLOADS"/afterPMi3/Pictures 2>/dev/null
}

# Main setup function.
main() {
    echo "[+] Starting first boot as root setup for i3 kali user."
    echo
    # Install some tools, applications, and clean up.
    # Uncomment code if necessary or comment out other tools you don't need.
    i3_config
    create_dirs
    setup_bg
    install_apt
    install_vivaldi    
    install_vscode    
    install_rust_tools "$CARGO_INSTALL_ALL"
    install_fonts
    install_ohmytmux
    install_fish_config
    install_starship
    install_nvm
    enable_fish
    remove_downloads

    # /usr/bin/vmhgfs-fuse .host:/kali /home/shared -o subtype=vmhgfs-fuse
    echo
    echo "[+] afterPMi3 setup is finished."
    echo "[+] Reboot or login as kali user to apply changes."
    echo "[+] These key commands will change for kali user:"
    echo "[+] To reboot press Alt-Shift-E, then press r."
    echo "[+] To log in press Alt-Shift-E, then press e."
    echo "[+] In the top right menu, select i3 and log in as kali."
}

main
