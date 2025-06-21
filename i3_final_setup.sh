#!/bin/bash

# Run this after i3 config for kali and package installs are finished. 
# Should be logged in as kali at this point.
# Check repositories and change the install commands when needed.
# Oh my tmux: https://github.com/gpakosz/.tmux
# Powerline fonts: https://github.com/powerline/fonts
# Oh my fish: https://github.com/oh-my-fish/oh-my-fish
# Starship: https://github.com/starship/starship
# nvm: https://github.com/nvm-sh/nvm
## https://github.com/jorgebucaran/fisher
## https://github.com/edc/bass

BASS=$(cat <<-END_TEXT
function nvm
    bass source ~/.nvm/nvm.sh --no-use ';' nvm $argv
end
END_TEXT
)

ZSHBASH=$(cat <<-END_TEXT
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:/usr/local/go/bin
source "$HOME/.cargo/env"
)
END_TEXT

install_the_goods() {
    echo "[+] Installing Oh my tmux"
    cd
    git clone --single-branch https://github.com/gpakosz/.tmux.git
    ln -s -f .tmux/.tmux.conf
    cp .tmux/.tmux.conf.local .
    cd /home/kali/Downloads/afterPMi3
    cp tmux.conf.txt /home/kali/.tmux.conf.local
    mkdir /home/kali/tmux_buffers
    mkdir /home/kali/tmux_logs
    echo "[+] Installing Powerline Fonts"
    mkdir /home/kali/Scripts
    cd /home/kali/Scripts || exit
    git clone https://github.com/powerline/fonts.git
    cd fonts
    ./install.sh
    cd /home/kali/Downloads/afterPMi3
    echo "[+] Copy new config.fish to fish"
    cp -a fishconfig.txt /home/kali/.config/fish/config.fish
    chsh -s /usr/bin/fish    
    echo "[+] Installing ohmyfish"
    curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
    echo "[+] Installing BobTheFish"
    omf install bobthefish
    echo "[+] Installing Starship"
    curl -sS https://starship.rs/install.sh | sh
    cp starship.toml /home/kali/.config
    echo "[+] Reload config.fish"
    source /home/kali/.config/fish/config.fish
    echo "[+] Create other directories"
    mkdir /home/kali/Work
    mkdir /home/kali/labs
    mkdir /home/kali/kali
    echo "[+] Installing nvm for node"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    fisher install edc/bass
    touch /home/kali/.config/fish/functions/nvm.fish
    echo "$BASS" > /home/kali/.config/fish/functions/nvm.fish
    echo "$ZSHBASH" >> /home/kali/.bashrc
    echo "$ZSHBASH" >> /home/kali/.zshrc
}

install_the_goods
cargo install rustscan
cargo install feroxbuster

echo "You may need to close this terminal and open a new one."