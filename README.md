This afterPMi3 script does a little more set up in Kali Linux after running [pimpmyi3](https://github.com/Dewalt-arch/pimpmyi3).

pimpmyi3 also downloads and runs [pimpmykali](https://github.com/Dewalt-arch/pimpmykali). When pimpmyi3 has finished and the VM is rebooted, it will automatically log in as root. Run afterPMi3.sh as root after pimpmyi3 is finished and you've rebooted.

When afterPMi3 is finished and the VM is logged in as the kali user (see steps below), it will have a different i3 config, fish shell with the tide theme (optional starship), oh-my-tmux, nvm (for node), fonts, a different background for each desktop, and more tools.

After the latest modifications to the script it may not work perfectly because it hasn't been fully tested yet (Date of this message: 07/26/25).

***Installed Packages***

- vivaldi
- code
- obsidian
- rustscan
- feroxbuster
- rg (ripgrep)
- bloodhound-cli
- oscanner
- xmlstarlet
- redis-tools
- jython (not tested)
- sipvicious
- zaproxy
- hurl
- guake
- pcmanfm
- fish
- tmux
- xsel
- hx (helix)
- subl (sublime-text)
- terminator
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

Bumblebee-status needs to be uncommented in the i3-wm config (~/.config/i3/config) and i3 reloaded, if you want to use it.
Starship needs to be uncommented in the fish config and the config reloaded, if you want to use it.

Coming soon, if it's needed...
