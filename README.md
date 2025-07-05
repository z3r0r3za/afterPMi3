This afterPMi3 script does a little more set up in Kali Linux after running [pimpmyi3](https://github.com/Dewalt-arch/pimpmyi3).

pimpmyi3 also downloads and runs [pimpmykali](https://github.com/Dewalt-arch/pimpmykali). When pimpmyi3 has finished and the VM is rebooted, it will automatically log in as root. Run afterPMi3.sh as root after pimpmyi3 is finished and you've rebooted.

When afterPMi3 is finished and the VM is logged in as the kali user (see steps below), it will have a different i3 config, fish shell with the tide theme (optional starship), oh-my-tmux, nvm (for node), fonts, a different background for each desktop, and more tools.

***Installed Packages***

- vivaldi
- code
- obsidian
- rustscan
- feroxbuster
- rg (ripgrep)
- bloodhound-cli
- zaproxy
- guake 
- pcmanfm 
- fish
- hx (helix)
- terminator 
- tmux 
- xsel 
- and some others...

***Other installs, configs, etc.***

- [nerd fonts](https://github.com/ryanoasis/nerd-fonts)
- [powerline](https://github.com/powerline/fonts) fonts
- fish config
    - [jorgebucaran/fisher](https://github.com/jorgebucaran/fisher)
    - [edc/bass](https://github.com/edc/bass)
    - [ilancosman/tide@v6](https://github.com/IlanCosman/tide)
- [starship](https://starship.rs/) and config
- [oh-my-tmux](https://github.com/gpakosz/.tmux) and config
- [nvm](https://github.com/nvm-sh/nvm)

***Complete Steps***

<div style="text-align: center;">
```
                              ;+->,                                 
                            .(vi3crl                                
                            `ccci3c]                                
                             '=i3-+'                                
                                     i{\(_`                         
                    ;+?~,           [cci3cn?`                       
                   1ci3cu+          -ccvi3ccn?`                     
                  .nccci31           l\ccci3ccn?`                   
                   ^[i3\-'             l\ccci3ccn?^                 
                           i3}\),        l\ccci3ccn?`               
          -I[I-           -cci3cv1,        l|ccci3ccx~              
         }i3ccc]          <ucci3ccv{,        l\ccci3cc1             
         \cci3c|           ,1vcci3ccv),        ljcci3vc1            
         '-|/|+'             ,{vci3vccv1,       'tcci3vc>           
                 >(ft1l        ,{vci3vccv}       "vcci3c}           
                ~cci3cc\l        ,{vci3vvcx.      |cvi3cx.          
                Ixcci3ccc\l        ,{vci3c1       fcci3cr.          
                 `?nci3vccc\l        ":+$"       icci3vc)           
                   `]nci3vccc\l                 !uci3ccv,           
                     `]nci3vccc\l             ,{cci3vcc<            
                       `]nci3vcccf[i=.___.+cIivcci3ccni             
                         `]nci3vvccccnrjrxvccccvi3cv1^              
                           `+fci3ccvcckalicvcci3cx}:                
                              '-|i3cccccccccvi3]I"                  
                                 '+l<_]]?[[!)+'                     
                                                                    
                                                                    
,'(\///////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\/////////////////\//|)',
:rf[???????????????????????????????????????????????????????????[fjI:
:jf~                                                            <ff:
:jf+                   .                              .         +fj:
:jf+      :()]     <)|1:      .1(()`      i))~        [)(,      ~fj:
:jf~      Irt|   l(jf_`       1frrt(      +ff]        (tj:      ~fj:
:jf~      Ijt1 ;1jj-`        -jj~ijf[     +ff?        1tj:      ~fj:
:jf+      Irt/{jt/^         irt}  ]tj<    _ff?        )fj:      ~fj:
:jf~      Irtj\1jf[^       ,f/r>><<j/rI   +ff]        )fj:      ~fj:
:jf+      ;rt(  ~ff/>     '/tj(//\\|jtf'  ~ff-        1tj:      ~fj:
:jf+      Ijt(   "{fj{^  .(tj_      ~jt/' +ff1I;II;I, )tj:      ~fj:
:jf~      If/{     <\t/! -f/}        [/f[ ~t/ffffffj] )/t,      ~fj:
:jf~      `''.      .'``  `'`         `'` .'''''''''. '''       +fj:
:jf+                                                            <ff:
:rf(++++++:   :+~~~~~~~~+~~~~~++~~~~~~~~~~~~+~~~~~~~~~~+~~~~~~++|fr:
'-[1()))))]   [|((((((((((((((((((((((((((((((((((((((((((((((()1]-'
```
</div>

Coming soon...
