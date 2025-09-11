afterPMi3.sh so I can pimp my pimpmyi3... or at least do a little more set up in Kali Linux after running [pimpmyi3](https://github.com/Dewalt-arch/pimpmyi3).

pimpmyi3 also downloads and runs [pimpmykali](https://github.com/Dewalt-arch/pimpmykali). When pimpmyi3 has finished (after running it with option 1) and the VM is rebooted, it will automatically log in as root. afterPMi3.sh should be git-cloned into the kali user's downloads directory and run as root from there after pimpmyi3 is finished and you've rebooted for the first time. Any packages that were already installed will be skipped. The kali user's password is "kali" so you will be asked to change the password when the script starts. After that it will run until it's finished. When the script reaches the end you should only have to press Alt+Shift+e, press e, check the top right menu at the log in screen to make sure i3wm is selected, then log in as kali:NEW_PASSWORD. The Mod key will be Win instead of Alt when you log in as the kali user.

When afterPMi3 is finished and the VM is logged in as the kali user, it will have a different i3 config, fish shell with the tide theme (optional starship), oh-my-tmux, nvm (for node), fonts, a different background for each desktop (can be flaky sometimes), and a lot more tools. Some of this isn't necessary for pentesting, but it's a good way to learn more about what you can do with i3wm. You should see conky displaying the i3 key commands on the desktop.

There have been some big changes to the script (09/11/25) and the way some items are installed. The changes still need to be tested.

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
- tnscmd10g
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
- bumblebee-status
- and some others...

***Other installs, configs, etc.***

- [nerd fonts](https://github.com/ryanoasis/nerd-fonts)
- [powerline fonts](https://github.com/powerline/fonts)
- fontawesome
- [bumblebee-status](https://github.com/tobi-wan-kenobi/bumblebee-status)
- fish config
    - [jorgebucaran/fisher](https://github.com/jorgebucaran/fisher)
    - [edc/bass](https://github.com/edc/bass)
    - [ilancosman/tide@v6](https://github.com/IlanCosman/tide)
- [starship](https://starship.rs/) and config
- [oh-my-tmux](https://github.com/gpakosz/.tmux) and config
- [nvm](https://github.com/nvm-sh/nvm)

Starship needs to be uncommented in the fish config and the config reloaded, if you want to use it.
