#!/usr/bin/env bash

# afterPMi3.sh: This will set up the i3 config, some other configs and install packages for the kali user.
# Use this script: after pimpmyi3 has finished, the VM has rebooted and is logged in as root.
# This script assumes that afterPMi3 has been cloned or downloaded into: /home/kali/Downloads/afterPMi3
# 
# Packages: zaproxy, guake, pcmanfm, helix, sublime-text, obsidian, fish, terminator, tmux, xsel, oscanner, 
# redis-tools, sipvicious, tnscmd10g, bloodhound-ce, autorecon, hurl, vivaldi, code, sublime, rustscan, 
# feroxbuster, ripgrep, cmake, alacritty, rssguard, pkg-config, conky-std.
#
# Configurations: i3, bumblebee-status, tmux, fish (and enables it), feh, powerline and other fonts, backgrounds, 
# Obsidian TEMPLATE.zip.
# /usr/bin/vmhgfs-fuse .host:/kali /home/shared -o subtype=vmhgfs-fuse

# cat /home/kali/Downloads/afterPMi3/afterPMi3.log to view logs.
exec > >(tee /home/kali/Downloads/afterPMi3.log) 2>&1

KUSER="/home/kali"

# Ensure the script is run as root
if [[ "$EUID" -ne 0 ]]; then
    echo "[!] This script was meant to be run as root right after running pimpmyi3"
    echo "and rebooting. You have to do pimpmyi3, log in as root and run it again."
    exit 1
fi

# Handle --help flag
if [[ "$1" == "--help" ]]; then
    cat <<EOF

Usage: ./afterPMi3.sh

This script configures Kali Linux for the kali user after running pimpmyi3.sh.
It installs additional tools, terminals, editors, fonts, i3 configs, and user 
shells. The Rust-based tools can take a little time to install so you can choose 
if or how they are installed:

  1) --all     Install rustscan, feroxbuster, ripgrep without prompting for each.
  2) (no flag) Interactive mode: Ask before each Rust tool installation.
  3) --none    Install everything, but skip installation of Rust tools.
  4) --all     Only Rust: Install Rust tools without prompting each time.
  5) (no flag) Only Rust: Ask before each Rust tool install.
  q)           Exit afterPMi3 without installing anything.
  
Note: This script was written to be run as root right after first reboot after running pimpmyi3, 
but using sudo or sudo su from a non-root user with full privileges might work, but it hasn't 
been tested. If it's run as non root with just sudo, a password may be required.

EOF
    exit 0
fi

# Display header and determine Rust tool install mode
# \e]8;;https://github.com/Dewalt-arch/pimpmyi3\apimpmyi3\e]8;;\a
clear
# ascii art of the blue i3 logo.
i3asciiart=$(base64 -d <<< "
H4sICBRPbGgAA2kzX29yaWdpbmFsLnR4dACllM+OgjAQxu8+RTWboCnFEG7+I3vkGVjU3UlI6hIO
RBsSCs++0AIWqMjqnOh08uObr9Mi9GbMnhVsMTmYbxCsJaMOJNHrhDMAlIjgdQIy9tQh2KjkWK8y
mqDZ1xLTfxC22C1UB33RTvypsURPsKv6G74nCEBlKsTuzySCFQsLbSUVcekqxD0ZeglHnzprYnRy
d0THjXEfqZPzVevGHaEY1AEQz/eIuhb1zB4i0kJLyKs9dXh2N1nPsiHD1hG42FNtMm1WM5RWLlWK
tQiVYBC+5r3xMzMm6pVe6FUiLI0PdRyW4dWOhoy8UcFUsRpCIYXzPoNBKn9LuZiteqUheKlEDBhN
6/NQFCQPCejsxlK3wlhs8MeiMUL6sHrsQ8kIhow25jd5POsxwgjDzKQC2KFxgsoIfbq3TgidLDOl
rH81xq5FzaggECeXJBVfTAz6EU0hlAwcyp4Bfr8jClJAmm+UmqdPXDmo4mhllAICb9EpmPJIGjja
nYLA9f35Chv93anP7OOY/QEe/7QW9QYAAA==
" | gunzip)

echo -e "\e[34m$i3asciiart\e[0m"
cat <<EOF

#########################################################################
##                       afterPMi3 - Kali Setup                        ##
#########################################################################

This script does a custom setup for the kali user after running pimpmyi3.
https://github.com/Dewalt-arch/pimpmyi3
It installs tools, editors, fonts, i3 and other configs, shells, etc.
To see a little more press q to exit and then try ./afterPMi3.sh --help
Setup starts when key is pressed. Choose your Rust tool install mode:

  [1] Include everything and all the Rust tools without prompting
  [2] Include everything while prompting to install each Rust tool
  [3] Include everything, but skip all the Rust tools
  [4] Only Rust: install all the tools
  [5] Only Rust: prompt for each tool  
  [q] Quit

EOF

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

    # Copy i3 new config and key commands files for kali user.
    cp /home/kali/Downloads/afterPMi3/config_i3.txt /home/kali/.config/i3/config
    chown kali:kali /home/kali/.config/i3/config
    cp /home/kali/Downloads/afterPMi3/i3_keys.txt /home/kali/.config/i3/i3_keys
    chown kali:kali /home/kali/.config/i3/i3_keys

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
    mkdir -p /home/kali/notes && chown kali:kali /home/kali/notes    
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

setup_subl() {
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
    echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' | \
        tee /etc/apt/sources.list.d/sublime-text.sources
}

# Check and install packages.
install_apt() {
    echo
    echo "[+] Checking and installing some missing packages."
    local packages=(
        "zaproxy" \
        "guake" \
        "pcmanfm" \
        "hx" \
        "sublime-text" \
        "fish" \
        "tmux" \
        "xsel" \
        "xmlstarlet" \
        "terminator" \
        "alacritty" \
        "rssguard" \
        "bumblebee-status" \
        "gnome-system-monitor" \
        "pamixer" \
        "hurl" \
        "galculator" \
        "oscanner" \
        "redis-tools" \
        "sipvicious" \
        "tnscmd10g" \
        "cmake" \
        "pkg-config" \
        "conky-std"
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
    echo "[+] Install and set up Starship config."
    cp /home/kali/Downloads/afterPMi3/starship.toml /home/kali/.config
    chown kali:kali /home/kali/.config/starship.toml   
}

install_alacritty_theme() {
    echo "[+] Set up alacritty themes."
    cd /home/kali/Downloads/afterPMi3/
    mkdir /home/kali/.config/alacritty
    mkdir /home/kali/.config/alacritty/themes
    unzip -q alacritty.zip || true
    cp /home/kali/Downloads/afterPMi3/alacritty/alacritty.toml /home/kali/.config/alacritty
    cp /home/kali/Downloads/afterPMi3/alacritty/dracula.toml /home/kali/.config/alacritty/themes
    cp /home/kali/Downloads/afterPMi3/alacritty/terafox.toml /home/kali/.config/alacritty/themes
    cp /home/kali/Downloads/afterPMi3/alacritty/zatonga.toml /home/kali/.config/alacritty/themes
    chown kali:kali /home/kali/.config/alacritty
    chown kali:kali /home/kali/.config/alacritty/*
}

install_bs_theme() {
    echo "[+] Set up bumblebee-status theme."
    cp /home/kali/Downloads/afterPMi3/solarpower.json /usr/share/bumblebee-status/themes/solarized-powerlined.json
}

install_conky() {
    echo "[+] Set up conky."
    unzip -q conky.zip || true
    cp /home/kali/Downloads/afterPMi3/conky/start_conky /usr/bin
    cp /home/kali/Downloads/afterPMi3/conky/conky_shortcuts_custom /usr/share/doc/conky-std
    cp /home/kali/Downloads/afterPMi3/conky/conky_custom /usr/share/doc/conky-std
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

install_autorecon() {
    sudo -u kali bash -c "pipx install git+https://github.com/Tib3rius/AutoRecon.git"
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

# Install Obsidian.
install_obsidian() {
    # Setup Obsidian template.
    cd /home/kali/Downloads/afterPMi3
    unzip -q TEMPLATE.zip
    if [ ! -d "/home/kali/notes/TEMPLATE" ]; then
        mv TEMPLATE /home/kali/notes
        chown -R kali:kali /home/kali/notes/*
        chown -R kali:kali /home/kali/notes/TEMPLATE/.obsidian
    fi

    echo
    echo "[+] Installing Obsidian."
    local RELEASE_INFO=$(curl -s -H "User-Agent: curl" https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest)
    local VERSION_NUM=$(echo "$RELEASE_INFO" | grep -o '"tag_name": *"[^"]*' | sed 's/.*"tag_name": *"//; s/".*//')
    local VERSION=${VERSION_NUM#v}
    local OBSIDIAN_URL="https://github.com/obsidianmd/obsidian-releases/releases/download/${VERSION_NUM}/obsidian_${VERSION}_amd64.deb"
    local OBSIDIAN="/home/kali/Downloads/obsidian_amd64.deb"

    # Check if code is installed.
    if command -v obsidian >/dev/null 2>&1; then
        echo "[+] Obsidian is already installed."
        return 0
    else
        wget -qO $OBSIDIAN "$OBSIDIAN_URL"
        if [[ -f "$OBSIDIAN" ]]; then
            dpkg -i $OBSIDIAN 2>/dev/null || true
            echo "[+] Downloaded and installed Obsidian."
        else
            echo "[-] Failed to download Obsidian. Please check or try again later."
            exit 1
        fi
    fi    
}

# Install Bloodhound CE that uses docker.
# https://bloodhound.specterops.io/get-started/quickstart/community-edition-quickstart
install_bloodhound_ce() {
    local BLOODHOUND_CLI="/opt/bloodhound-cli"
    if [[ -f "$BLOODHOUND_CLI" ]]; then
        echo "[+] Looks like bloodhound-cli already exists inside the opt directory."
    else
        cd /opt
        wget https://github.com/SpecterOps/bloodhound-cli/releases/latest/download/bloodhound-cli-linux-amd64.tar.gz
        tar -xvzf bloodhound-cli-linux-amd64.tar.gz
        cd bloodhound-cli-linux-amd64
        ./bloodhound-cli install
    fi
}

install_jython() {
    # https://www.jython.org/installation.html
    # maven-metadata URL for extracting the latest version number.
    METADATA_URL="https://repo1.maven.org/maven2/org/python/jython-installer/maven-metadata.xml"
    METADATA_CONTENTS=$(curl -s "$METADATA_URL")

    # Check for xmlstarlet and use it if it's installed.
    if ! command -v xmlstarlet &> /dev/null; then
        echo "[-] xmlstarlet was not found. Using grep and sed."
        LATEST_VERSION=$(echo "$METADATA_CONTENTS" | grep -oP '<latest>[^<]+' | sed 's/<latest>//;s/<.*//')
    else    
        LATEST_VERSION=$(xmlstarlet sel -t -v "//latest" -n < <(curl -s "$METADATA_URL"))    
    fi

    # https://repo1.maven.org/maven2/org/python/jython-installer/2.7.4/jython-installer-2.7.4.jar
    #INSTALLER_URL="https://repo1.maven.org/maven2/org/python/jython-installer/$LATEST_VERSION/jython-installer-$LATEST_VERSION.jar"
    INSTALLER_URL="https://repo1.maven.org/maven2/org/python/jython-standalone/$LATEST_VERSION/jython-standalone-$LATEST_VERSION.jar"

    INSTALL_DIR="jython$LATEST_VERSION"

    # Create installation directory.
    mkdir -p "/home/kali/$INSTALL_DIR"

    # Download the Jython installer JAR.
    echo "[+] Downloading $INSTALL_DIR standalone"
    wget -q "$INSTALLER_URL" --directory "/home/kali/$INSTALL_DIR" || true

    # Check if download was successful from previous command.
    if [ $? -ne 0 ]; then
        echo "[-] Failed to download Jython standalone. Check the URL and try again later."
    fi

    # Give owner as kali.
    chown kali:kali "/home/kali/$INSTALL_DIR"
    chown -R kali:kali "/home/kali/$INSTALL_DIR/*"   
}

# Paths for go and cargo copied to zshrc/bashrc.
# The back slashes prevent variables from printing values.
datetime=$(date +"%Y-%m-%d %H:%M:%S")
ZSHBASH=$(cat <<-END_TEXT
# These paths were added on $datetime
# Paths for pipx
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
        echo "[*] --all entered: Installing all 3 rust tools."
    elif [[ "$ALL" == "--none" ]]; then
        echo "[*] --none entered: Skipping all 3 rust tools."
        return 0
    fi

    # Prompt user to install each one if no --all option.
    ask_install() {
        local tool="$1"

        # Return and continue installation without asking.
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
}

rust_message() {
    local CI="$1"
    local OR="$2"
    if [ "$CI" == "--all" ]; then
        echo "[+] Installing everything...."
        echo "--------------------------------------------------------------------"
        echo
    elif [ "$CI" == "--none" ]; then
        echo "[+] Installing everything except the Rust tools."
        echo "--------------------------------------------------------------------"
        echo
    elif [[ "$CI" == "--all" && "$OR" == "--all" ]]; then
        echo "[+] Installing only the Rust tools."
        echo "--------------------------------------------------------------------"
        echo
    elif [[ "$CI" == "--none" && "$OR" == "" ]]; then
        echo "[+] Installing only the Rust tools, prompting for each one."
        echo "--------------------------------------------------------------------"
        echo
    fi    
}

w_rust_tools() {
    rust_message "$CARGO_INSTALL"
    i3_config
    create_dirs
    setup_bg
    setup_subl
    install_apt
    install_fonts
    install_ohmytmux
    install_fish_config
    install_starship
    install_alacritty_theme
    install_bs_theme
    install_conky
    install_nvm
    install_autorecon
    install_vivaldi
    install_vscode
    install_obsidian
    install_bloodhound_ce
    install_jython
    install_rust_tools "$CARGO_INSTALL"
    enable_fish
    remove_downloads
    finished
}

wo_rust_tools() {
    rust_message "$CARGO_INSTALL"
    i3_config
    create_dirs
    setup_bg
    setup_subl
    install_apt
    install_fonts
    install_ohmytmux
    install_fish_config
    install_starship
    install_alacritty_theme
    install_bs_theme
    install_conky
    install_nvm
    install_autorecon
    install_vivaldi
    install_vscode
    install_obsidian
    install_bloodhound_ce
    install_jython
    enable_fish
    remove_downloads
    finished
}

o_rust_tools() {
    rust_message "$CARGO_INSTALL" "$ONLY_RUST"
    install_rust_tools "$CARGO_INSTALL"
    finishedrust
}

# Print when setup is finished.
finished() {
    echo
    echo "[+] afterPMi3 is finished."
    echo "There should be a log file here: /home/kali/Downloads/afterPMi3.log"
    echo "You can check the log file for any errors that might have happened for"
    echo "whatever reason. Sometimes a particular install will fail."
    echo "------------------------------------------------------------------------"
    echo "You can find the Bloodhound-CE password in the afterPMi3.log"
    echo "The Bloodhound-CE default password line will look something like this:"
    echo "...log in as admin with this password: mSohlqWnVCflV60PzWQKdqYHxYGM3zUs"
    echo "There may be other ways to get the password if you don't have it."
    echo "[+] Get admin password: bloodhound-cli config get default_password"
    echo "[+] Access the BloodHound at: http://127.0.0.1:8080/ui/login"
    echo "------------------------------------------------------------------------"
    echo "[+] Reboot or login as kali user to apply changes."
    echo "[+] Before reboot: To reboot press Alt-Shift-E, then press r."
    echo "[+] Before reboot: To log in press Alt-Shift-E, then press e."
    echo "[+] Then in the top right menu, select i3 and log in as kali."
}

# Print when setup is finished.
finishedrust() {
    echo
    echo "[+] afterPMi3 has finished the Rust tools installation."
    echo "If any errors happened, you can find them in the log file:"
    echo "/home/kali/Downloads/afterPMi3.log"
    echo "-------------------------------------------------------------------"
}

while true; do
    read -n1 -p "Enter option [1/2/3/4/5/q] or press q to exit: " rust_choice
    case "$rust_choice" in
        1) w_rust_tools; CARGO_INSTALL="--all"; break ;;
        2|"") w_rust_tools; CARGO_INSTALL=""; break ;;
        3) wo_rust_tools; CARGO_INSTALL="--none"; break ;;        
        4) o_rust_tools; CARGO_INSTALL="--all"; ONLY_RUST="--all"; break ;;
        5) o_rust_tools; CARGO_INSTALL=""; ONLY_RUST=""; break ;;
        [Qq]) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid input. Please enter 1, 2, 3, 4, or q to exit." ;;
    esac
done
