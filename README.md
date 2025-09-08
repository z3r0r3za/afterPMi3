afterPMi3.sh so I can pimp my pimpmyi3... or at least do a little more set up in Kali Linux after running [pimpmyi3](https://github.com/Dewalt-arch/pimpmyi3).

pimpmyi3 also downloads and runs [pimpmykali](https://github.com/Dewalt-arch/pimpmykali). When pimpmyi3 has finished (after running it with option 1) and the VM is rebooted, it will automatically log in as root. afterPMi3.sh should be cloned and run as root after pimpmyi3 is finished and you've rebooted for the first time. Packages there were already installed will be skipped.

When afterPMi3 is finished and the VM is logged in as the kali user, it will have a different i3 config, fish shell with the tide theme (optional starship), oh-my-tmux, nvm (for node), fonts, a different background for each desktop, and a lot more tools. Some of this isn't necessary for pentesting, but some of it can be.

All you should have to do when it's done is press Alt+Shift+e, then press e, at the log in screen check the top right menu to make sure i3 is selected, then log in as kali:kali. The Mod key will be Win instead of Alt for the kali user.

During a recent test run (09/07/25) one of the rust tools (feroxbuster) threw some errors during install. It appeared to be an issue unrelated to this script.

***Installed Packages***

- vivaldi
- code
- obsidian
- rustscan
- feroxbuster
- rg (ripgrep)
- bloodhound-cli
- autorecon
- oscanner
- xmlstarlet
- redis-tools
- jython (not tested)
- sipvicious
- zaproxy
- hurl
- guake
- pcmanfm
- rssguard
- fish
- tmux
- xsel
- hx (helix)
- subl (sublime-text)
- terminator
- alacritty
- conky (conky-std)
- some others...

***Other installs, configs, etc.***

- [nerd fonts](https://github.com/ryanoasis/nerd-fonts)
- [powerline fonts](https://github.com/powerline/fonts)
- [bumblebee-status](https://github.com/tobi-wan-kenobi/bumblebee-status)
- fish config
    - [jorgebucaran/fisher](https://github.com/jorgebucaran/fisher)
    - [edc/bass](https://github.com/edc/bass)
    - [ilancosman/tide@v6](https://github.com/IlanCosman/tide)
- [starship](https://starship.rs/) and config
- [oh-my-tmux](https://github.com/gpakosz/.tmux) and config
- [nvm](https://github.com/nvm-sh/nvm)

***Complete Steps***

Coming soon, if it's needed...

Bumblebee-status needs to be uncommented in the i3-wm config (~/.config/i3/config) and i3 reloaded, if you want to use it.
Starship needs to be uncommented in the fish config and the config reloaded, if you want to use it.
