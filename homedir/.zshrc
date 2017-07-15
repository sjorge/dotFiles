## .zshrc
# by Jorge Schrauwen <jorge@blackdot.be>
# Version 20160621001
#         YYYYMMDD###

# How to install
# curl -sk "https://docu.blackdot.be/getRaw.php?onlyCode=true&id=configuration:zsh" -o ~/.zshrc 
#
# Change Log
# - 20160621: --- - optimizations
# - 20160621: fix - if .aliases is missing initial exit indicator was fasle
# - 20160320: fix - color ls on SmartOS, drop obd support
# - 20160219: fix - fix vncviewer alias
# - 20151128: --- - cleanup and removal of old code
# - 20151001: fix - support new pkgsrc layout on OSX
# - 20141225: new - added 'developer' theme (same as dual but with git helpers)
# - 20141225: new - switched to promptinit, converted themes and renamed minimal
# - 20141225: new - added CMD_SAFE_WRAP (defaults to 1)
# - 20141225: --- - switch to selective nocorrect/noglob
# - 20141225: new - enable dirstack, enable auto rehash, extra MacOSX helpers
# - 20141225: --- - set NOFANCY_PROMPT to disable UTF-8 prompt
# - 20141225: fix - broken dual and gentoo-server themes
# - 20141225: --- - reworked flow
# - 20141225: new - NZSHRC override via .zopts
# - 20141225: new - local option override (.zopts)
# - 20141225: fix - updated automatic update function
# - 20141223: new - disabled beep
# - 20141223: fix - disabled homedir autocomplete
# - 20141008: new - SmartOS support LX brand /native
# - 20141003: new - OpenBSD pkg_add helper
# - 20141002: --- - Solaris re-order PATH/MANPATH
# - 20141002: --- - avoid double sourcing, .zprofile -> .zlocal
# - 20140820: fix - MacOSX Yosemite ctr+r works
# - 20140727: fix - Solaris zshenable works
# - 20140727: fix - don't butcher EDITOR
# - 20140726: new - SmartOS zone support
# - 20140629: new - MacOSX pkgsrc on OSX (http://saveosx.org)
# - 20140421: new - OpenBSD color ls
# - 20131013: new - Solaris zfs compatible rsync alias
# - 20131010: --- - path cleanup
# - 20131009: new - Solaris path tweaks + colorls
# - 20130730: fix - OmniOS manpages
# - 20130716: fix - Solaris sbin handling
# - 20130629: new - OmniOS obd repository support
# - 20130625: fix - OmniOS fixed broken isaexec
# - 20130621: fix - OmniOS add sbin only when staff
# - 20130520: new - OmniOS support
# - 20120823: new - automatic update
# - 20120821: new - disable UTF-8 check-mark with .znofancy

# {{{ updater
    NZSHRC="https://docu.blackdot.be/getRaw.php?onlyCode=true&id=configuration:zsh"
    CHECK_UPDATE=1
    AUTO_UPDATE=1
# }}}

# {{{ options
    ## change directory 
    setopt auto_cd
    
    ## enable command correction
    setopt correct
    #setopt correct_all  

    ## prevent file overwrite
    setopt no_clobber

    ## pound sign in interactive prompt
    setopt interactive_comments 

    ## superglobs
    unsetopt case_glob
    
    ## expansions performed in prompt
    setopt prompt_subst
    setopt magic_equal_subst

    ## prompt about background jobs on exit
    setopt check_jobs

    ## notify on job complete
    setopt notify
    
    ## disable beep
    unsetopt beep
    setopt no_beep
    
    ## automatic rehash
    setopt nohashdirs
    
    ## make some commands safer
    CMD_SAFE_WRAP=0
    setopt mark_dirs

    ## include local options
    [[ -e ~/.zopts ]] && source ~/.zopts
# }}}

# {{{ history
    # history file
    HISTFILE=~/.zhistory
    HISTSIZE=10000
    SAVEHIST=10000

    # share history file
    setopt share_history
    setopt inc_append_history

    # ignore duplicates
    setopt hist_ignore_all_dups
    
    # ignore entries starting with a space
    setopt hist_ignore_space
# }}}

# {{{ dirstack
    DIRSTACKSIZE=20
    setopt autopushd pushdsilent pushdtohome pushdminus
    setopt pushdignoredups # ignore dups
# }}}

# {{{ keybindings
    # generic
    bindkey "\e[1~" beginning-of-line # Home
    bindkey "\e[4~" end-of-line # End
    bindkey "\e[5~" beginning-of-history # PageUp
    bindkey "\e[6~" end-of-history # PageDown
    bindkey "\e[2~" quoted-insert # Ins
    bindkey "\e[3~" delete-char # Del
    bindkey "\e[5C" forward-word
    bindkey "\eOc" emacs-forward-word
    bindkey "\e[5D" backward-word
    bindkey "\eOd" emacs-backward-word
    bindkey "\e\e[C" forward-word
    bindkey "\e\e[D" backward-word
    bindkey "\e[Z" reverse-menu-complete # Shift+Tab
    bindkey '^R' history-incremental-search-backward
    bindkey ' ' magic-space # becasue I am lazy

    # for rxvt
    bindkey "\e[7~" beginning-of-line # Home
    bindkey "\e[8~" end-of-line # End

    # for non RH/Debian xterm, can't hurt for RH/Debian xterm
    bindkey "\eOH" beginning-of-line
    bindkey "\eOF" end-of-line

    # for freebsd/darwin console
    bindkey "\e[H" beginning-of-line
    bindkey "\e[F" end-of-line
# }}}

# {{{ functions
    # update .zshrc
    zshupdate() { 
        # main
        if [ -z "`which curl`" ]; then
            echo 'Please install curl!'
            exit
        fi
        NV=`curl -sk ${NZSHRC} | head -n3 | tail -n1 | awk '{ print $3 }'`
        OV=`cat ~/.zshrc | head -n3 | tail -n1 | awk '{ print $3 }'`
        [ -z "${NV}" ] && NV=0
        
        if [ ${NV} -gt ${OV} ]; then
            echo -n "[>>] Updating from ${OV} to ${NV} ...\r"
            mv ~/.zshrc ~/.zshrc.old
            curl -sk ${NZSHRC} -o ~/.zshrc
            source ~/.zshrc
            echo '[OK]'
        else
            echo "[OK] No update needed."
        fi
    }

    # auto update check
    if [ ${CHECK_UPDATE} -gt 0 ]; then
        if [ `find ~/.zshrc -mmin +1440` ]; then
            touch ~/.zshrc
            NV=`curl -sk -m 3 ${NZSHRC} | head -n3 | tail -n1 | awk '{ print $3 }'`
            OV=`cat ~/.zshrc | head -n3 | tail -n1 | awk '{ print $3 }'`
            [ -z "${NV}" ] && NV=0
        
            if [ ${NV} -gt ${OV} ]; then
                if [ ${AUTO_UPDATE} -gt 0 ]; then
                    zshupdate
                else
                    echo "Please run zshupdate to update .zshrc to version ${NV}!"
                fi
            fi
        fi
    fi

    # remove ssh known_hosts key
    delete_sshhost() {
        if [[ -z "$1" ]] ; then
            echo "usage: \e[1;36mdelete_sshhost \e[1;0m< host >"
            echo "       Removes the specified host from ssh known host list"
        else
            sed -i -e "/$1/d" $HOME/.ssh/known_hosts
        fi
    }
    
    # zshenable helper
    zshenable() {
        case $OSTYPE in 
            linux*|darwin*|openbsd*)
                chsh -s $(which zsh)
            ;;
            solaris*)
                pfexec /usr/sbin/usermod -s $(which zsh) $(id -n -u)
            ;;
            *)
                echo "No zshenable implemented for $OSTYPE."
            ;;
        esac
    }
    
    # zshdisable helper
    zshdisable() {
        case $OSTYPE in 
            linux*|darwin*|openbsd*)
                chsh -s $(which bash)
            ;;
            solaris*)
                pfexec /usr/sbin/usermod -s $(which bash) $(id -n -u)
            ;;
            *)
                echo "No zshdisable implemented for $OSTYPE."
            ;;
        esac
    }
# }}}

# {{{ advanced
    ## cleanup aliases
    noglob unalias -m cd cp ls mv rm 

    ## fix url quote's
    if [[ ${ZSH_VERSION//\./} -ge 420 ]] ; then
         autoload -U url-quote-magic
         zle -N self-insert url-quote-magic
    fi

    ## os specific
    case $OSTYPE in linux*)
        # detect root or staff
        [ $UID -eq 0 ] && WANT_SBIN=1
        [ $(groups | grep -c sudo) -gt 0 ] && WANT_SBIN=1
        [ $(groups | grep -c wheel) -gt 0 ] && WANT_SBIN=1
  
        # colorization
        eval $(dircolors)
        [ -f /etc/DIR_COLORS ] && eval $(dircolors -b /etc/DIR_COLORS)
        [ -f ~/.dir_colors ] && eval $(dircolors -b ~/.dir_colors)

        alias ls="ls --group-directories-first"
        if [ -n "${LS_COLORS}" ]; then
            export ZLSCOLORS="${LS_COLORS}"
            alias ls="${aliases[ls]:-ls} --color=auto"
            alias grep="${aliases[grep]:-grep} --color=auto"
        fi
  
        # LX BrandZ
        if [ -d /native ]; then
            export PATH=$PATH:/native/usr/bin
            if [ -n $WANT_SBIN ]; then
                export PATH=$PATH:/native/sbin
                export PATH=$PATH:/native/usr/sbin
            fi
        fi
    ;; esac
    case $OSTYPE in solaris*)
        # detect root or staff
        [ $UID -eq 0 ] && WANT_SBIN=1
        [ $(groups | grep -c staff) -gt 0 ] && WANT_SBIN=1
        [ $(groups | grep -c sysadmin) -gt 0 ] && WANT_SBIN=1
        export MANPATH=/usr/share/man

        # add /usr/sbin if wanted
        [ $(echo $PATH | grep -c '/usr/sbin:')  -eq 0 ] && 
            [ -n $WANT_SBIN ] && export PATH=$PATH:/usr/sbin

        # check for gnu
        export PATH=$(echo $PATH | /bin/sed -r 's#:/usr/gnu/s?bin##g')
        if [ -d /usr/gnu ]; then
            export PATH=$PATH:/usr/gnu/bin
            [ -n $WANT_SBIN ] && export PATH=$PATH:/usr/gnu/sbin

            # selective gnu / colorization
            [ -e /usr/gnu/bin/sed ] && alias sed='/usr/gnu/bin/sed'
            [ -e /usr/gnu/bin/diff ] && alias diff='/usr/gnu/bin/diff'
            [ -e /usr/gnu/bin/tar ] && alias tar='/usr/gnu/bin/tar'
            [ -e /usr/gnu/bin/rm ] && alias rm='/usr/gnu/bin/rm'
        fi
  
        # check for pkgsrc (smartos)
        export PATH=$(echo $PATH | /bin/sed -r 's#/opt/local/s?bin:##g')
        export MANPATH=$(echo $MANPATH | /bin/sed -r 's#/opt/local/man:##g')
        if [ -d /opt/local ]; then
            export MANPATH=/opt/local/man:$MANPATH
            export PATH=/opt/local/bin:$PATH
            [ -n $WANT_SBIN ] && export PATH=/opt/local/sbin:$PATH
        fi

        # check for omniti repository (omnios)
        export PATH=$(echo $PATH | /bin/sed -r 's#/opt/omni/s?bin:##g')
        export MANPATH=$(echo $MANPATH | /bin/sed -r 's#/opt/omni/share/man:##g')
        if [ -d /opt/local ]; then
            export MANPATH=$MANPATH:/opt/omni/share/man
            export PATH=$PATH:/opt/omni/bin
            [ -n $WANT_SBIN ] && export PATH=$PATH:/opt/omni/sbin
        fi

        # check for local
        export PATH=$(echo $PATH | /bin/sed -r 's#/usr/local/s?bin:##g')
        if [ -d /usr/local ]; then
            export PATH=/usr/local/bin:$PATH
            [ -n $WANT_SBIN ] && export PATH=/usr/local/sbin:$PATH
        fi

        # check for opencsw
        export PATH=$(echo $PATH | /bin/sed -r 's#:/opt/csw/s?bin##g')
        if [ -d /opt/csw ]; then
            export PATH=$PATH:/opt/csw/gnu:/opt/csw/bin
            [ -n $WANT_SBIN ] && export PATH=$PATH:/opt/csw/sbin
        fi

        # colorization
        case $(which ls) in
          /opt/local/bin/ls) alias ls='ls --color' ;;
          /usr/bin/ls) alias ls='ls --color' ;;
          /usr/gnu/bin/ls) ls='ls --color=auto' ;;
        esac
        case $(which grep) in
          /opt/local/bin/grep) alias grep='grep --color=auto' ;;
          /usr/gnu/bin/grep) alias grep='grep --color=auto' ;;
        esac
    ;; esac
    case $OSTYPE in openbsd*)
        # set PKG_PATH
        export PKG_PATH=http://ftp.openbsd.org/pub/OpenBSD/`uname -r`/packages/`uname -m`/  

        # colorization
        [ -e /usr/local/bin/colorls ] && alias ls='/usr/local/bin/colorls -G'
    ;; esac
    case $OSTYPE in darwin*)
        # colorization
        export CLICOLOR=1
        alias ls='ls -G'

        # macports (with gnu)
        if [ -e /opt/local/bin/port ]; then
            export PATH=/opt/local/libexec/gnubin:/opt/local/bin:/opt/local/sbin:$PATH
            export MANPATH=/opt/local/share/man:$MANPATH
            if [ -f ~/.dir_colors ]; then
                eval $(dircolors -b ~/.dir_colors)
                export ZLSCOLORS="${LS_COLORS}"
                unalias ls &> /dev/null
                alias ls='ls --color=auto'
            fi
            if [ -e /opt/local/bin/python2 ]; then
                alias python='/opt/local/bin/python2'
            fi
        fi
  
        # pkgsrc
        if [ -e /opt/pkg/bin/pkgin ]; then
            export PATH=/opt/pkg/gnu/bin:/opt/pkg/bin:/opt/pkg/sbin:$PATH
            export MANPATH=/opt/pkg/man:$MANPATH
            if [ -f ~/.dir_colors ]; then
                eval $(dircolors -b ~/.dir_colors)
                export ZLSCOLORS="${LS_COLORS}"
                unalias ls &> /dev/null
                alias ls='ls --color=auto'
            fi
            alias pkgin='sudo pkgin'
        elif [ -e /usr/pkg/bin/pkgin ]; then
            export PATH=/usr/pkg/gnu/bin:/usr/pkg/bin:/usr/pkg/sbin:$PATH
            export MANPATH=/usr/pkg/man:$MANPATH
            if [ -f ~/.dir_colors ]; then
                eval $(dircolors -b ~/.dir_colors)
                export ZLSCOLORS="${LS_COLORS}"
                unalias ls &> /dev/null
                alias ls='ls --color=auto'
            fi
            alias pkgin='sudo pkgin'
        fi
        
        ## helpers        
        function vnc() {
            which vncviewer &> /dev/null
            if [ $? -eq 0 ]; then
                vncviewer $@
            else
                open vnc://$@
            fi
        }
    ;; esac

    ## host specific
    case ${HOST:r} in
        (axion*|tachyon*|photon*)
            # proper UTF-8
            export LANG=en_US.UTF-8

            # host color
            PROMPT_HOST_COLOR=green
        ;;
        (exosphere*|crust*)
            PROMPT_HOST_COLOR=red
        ;;
        *)
            # default host color
            PROMPT_HOST_COLOR=blue
        ;;  
    esac
  
    ## local configuration
    [[ -e ~/.zlocal ]] && source ~/.zlocal
# }}}

# {{{ auto completion
    ## base
    autoload -U compinit && compinit

    ## complete from withing word
    setopt complete_in_word
    setopt always_to_end

    ## complete aliases
    setopt complete_aliases

    ## enable caching
    zstyle ':completion::complete:*' use-cache on
    zstyle ':completion::complete:*' cache-path ~/.zcache
    
    ## enable case-insensitive completion
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
    
    ## various tweaks
    zstyle '*' single-ignored show
    
    zstyle ':completion:*' completer _complete _match _approximate
    zstyle ':completion:*:match:*' original only
    zstyle ':completion:*:approximate:*' max-errors 1 numeric
    
    zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'
    
    ## history
    zstyle ':completion:*:history-words' stop yes
    zstyle ':completion:*:history-words' remove-all-dups yes
    zstyle ':completion:*:history-words' list false
    zstyle ':completion:*:history-words' menu yes
    
    ## directories
    zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
    zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
    zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
    zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
    zstyle ':completion:*' squeeze-slashes true
    
    ## ignore completions for commands that we dont have
    zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
    
    ## array completion
    zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
    
    ## group matches and describe
    zstyle ':completion:*:*:*:*:*' menu select
    zstyle ':completion:*:matches' group 'yes'
    zstyle ':completion:*:options' description 'yes'
    zstyle ':completion:*:options' auto-description '%d'
    zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
    zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
    zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
    zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
    zstyle ':completion:*:default' list-prompt '%S%M matches%s'
    zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
    zstyle ':completion:*' group-name ''
    zstyle ':completion:*' verbose yes
    
    ## pretty menu's
    zstyle ':completion:*' menu select=1
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    setopt auto_menu    # show menu on 2nd <tab>
    setopt list_rows_first  # use row list if possible

    ## prevent re-suggestion
    zstyle ':completion:*:(scp|rm|kill|diff):*' ignore-line yes
    #zstyle ':completion:*:rm:*' file-patterns '*:all-files'

    ## enable killall menu (linux)
    zstyle ':completion:*:processes-names' command 'ps -u $(whoami) -o comm='
    zstyle ':completion:*:processes-names' menu yes select
    zstyle ':completion:*:processes-names' force-list always    

    ## enable kill menu (linux)   
    case $OSTYPE in 
        linux*|darwin*|openbsd*)
            if [ $(id -u) -eq 0 ]; then
                zstyle ':completion:*:*:*:*:processes' command 'ps -A -o pid,user,pcpu,pmem,args -w'
            else
                zstyle ':completion:*:*:*:*:processes' command 'ps -u $(whoami) -o pid,user,pcpu,pmem,args -w'
            fi
        ;;
        solaris*)
            if [ $(id -u) -eq 0 ]; then
                zstyle ':completion:*:*:*:*:processes' command 'ps -A -o pid,user,pcpu,pmem,args'
            else
                zstyle ':completion:*:*:*:*:processes' command 'ps -u $(whoami) -o pid,user,pcpu,pmem,args'
            fi
        ;;
    esac
    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;32'
    zstyle ':completion:*:*:kill:*' menu yes select
    zstyle ':completion:*:*:kill:*' force-list always
    zstyle ':completion:*:*:kill:*' insert-ids single
    
    ## simple pargs complete
    case $OSTYPE in 
        solaris*)
            compdef _pids pargs
            zstyle ':completion:*:*:pargs:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;32'
            zstyle ':completion:*:*:pargs:*' menu yes select
            zstyle ':completion:*:*:pargs:*' force-list always
            zstyle ':completion:*:*:pargs:*' insert-ids single
        ;;
    esac
    
    ## man pages
    zstyle ':completion:*:manuals' separate-sections true
    zstyle ':completion:*:manuals.(^1*)' insert-sections true

    ## enable make completion
    compile=(all clean compile disclean install remove uninstall)
    compctl -k compile make
    
    ## user completion cleanup
    zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache avahi backup beaglidx bin cacti canna clamav daemon \
        dladm dbus distcache dovecot fax ftp games gdm gkrellmd gopher gnats \
        hacluster haldaemon halt hsqldb ident junkbust ldap lp irc list libuuid \
        listen mdns mail mailman mailnull mldonkey mysql man messagebus \
        netadm netcfg nagios noaccess nobody4 nuucp \
        named netdump news nfsnobody nobody nscd ntp nut nx openvpn openldap \
        operator pcap pkg5srv postfix postgres proxy privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm shutdown statd squid sshd sync sys syslog uucp vcsa \
        smmsp svctag upnp unknown webservd www-data xfs xvm zfssnap '_*'
        
    ## hostname completion
    if [ ! -f ~/.ssh/config ]; then
        [ -f ~/.ssh/known_hosts ] && rm ~/.ssh/known_hosts
        mkdir -p ~/.ssh
        echo "HashKnownHosts no" >>! ~/.ssh/config
        chmod 0600 ~/.ssh/config
    fi
    zstyle -e ':completion:*:hosts' hosts 'reply=(
        ${=${=${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) 2>/dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
        ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*}
        ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
    )'

    ## ssh/scp/rsync
    zstyle ':completion:*:(scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
    zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
    zstyle ':completion:*:ssh:*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
    zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
    zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost ip6-allnodes ip6-allrouters ip6-localnet ip6-mcastprefix broadcasthost
    zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
    zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*' 'fe00::*' 'ff00::*' 'ff02::*'
# }}}

# {{{ auto correction
    ## disable auto correct
    alias cd='nocorrect cd'
    alias cp='nocorrect cp'
    alias gcc='nocorrect gcc'
    alias grep='nocorrect grep'
    alias ln='nocorrect ln'
    alias man='nocorrect man'
    alias mkdir='nocorrect mkdir'
    alias mv='nocorrect mv'
    alias rm="nocorrect ${aliases[rm]:-rm}"
    which sshpass &> /dev/null ; [ $? -eq 0 ] && alias sshpass='nocorrect sshpass'
    
    ## disable globbing.
    alias find='noglob find'
    alias ftp='noglob ftp'
    alias history='noglob history'
    alias locate='noglob locate'
    alias rsync='noglob rsync'
    alias scp='noglob scp'
    alias sftp='noglob sftp'
    alias ssh='noglob ssh'
# }}}

# {{{ safe command wrap
    if [ ${CMD_SAFE_WRAP} -gt 0 ]; then
        alias rm="${aliases[rm]:-rm} -i"
        alias mv="${aliases[mv]:-mv} -i"
        alias cp="${aliases[cp]:-cp} -i"
        alias ln="${aliases[ln]:-ln} -i"
        alias mkdir="${aliases[mkdir]:-mkdir} -p"
    fi
# }}}

# {{{ prompt
    ## enable colors and prompt module
    autoload -U colors && colors
    autoload -Uz promptinit && promptinit

    ## checkmarks
    PROMPT_CO='.'
    PROMPT_CE='!'

    ## create themes
    prompt_gentoo_setup() {
        PROMPT='%(!.%{$fg_bold[red]%}.%{$fg_bold[green]%}%n@)%m %{$fg_bold[blue]%}%(!.%1~.%~) %#%{$reset_color%} '
        RPROMPT=''
    }
    prompt_themes=($prompt_themes gentoo)
    
    prompt_gentoo_server_setup() {
        PROMPT='%(!.%{$fg_bold[red]%}.%{$fg_bold[yellow]%}%n@)%m %{$fg_bold[blue]%}%(!.%1~.%~) %#%{$reset_color%} '
        RPROMPT=''
    }
    prompt_themes=($prompt_themes gentoo_server)

    prompt_compact_setup() {
        PROMPT=$'%{$fg_bold[grey]%}-(%{$reset_color%}%{$fg_bold[white]%}%1~%{$reset_color%}%{$fg_bold[grey]%})-[%{$reset_color%}%(?,%{$fg_bold[green]%}$PROMPT_CO%{$reset_color%},%{$fg_bold[red]%}$PROMPT_CE%{$reset_color%})%{$fg_bold[grey]%}]-%{$reset_color%}%(!.%{$fg_bold[red]%}.%{$fg_bold[yellow]%}){%{$reset_color%} '
        RPROMPT=$'%(!.%{$fg_bold[red]%}.%{$fg_bold[yellow]%})}%{$reset_color%}%{$fg_bold[grey]%}-(%{$reset_color%}%{$fg_bold[$PROMPT_HOST_COLOR]%}%n@%m%{$reset_color%}%{$fg_bold[grey]%})-%{$reset_color%}'
    }
    prompt_themes=($prompt_themes compact)
    
    prompt_dual_setup() {
        PROMPT=$'%{$fg_bold[grey]%}[%{$fg_bold[$PROMPT_HOST_COLOR]%}%m %{$fg_bold[grey]%}:: %(!.%{$fg_bold[red]%}.%{$fg_bold[green]%})%n%{$fg_bold[grey]%}][%{$fg_bold[white]%}%~%{$fg_bold[grey]%}]\n[%(?,%{$fg_bold[green]%}$PROMPT_CO%{$reset_color%},%{$fg_bold[red]%}$PROMPT_CE%{$reset_color%})%{$fg_bold[grey]%}]%(!.%{$fg_bold[red]%}#.%{$fg_bold[green]%}$)%{$reset_color%} '
        RPROMPT=''
    }   
    prompt_themes=($prompt_themes dual)
    
    prompt_developer_setup() {
        _developer_git() { 
            git status 2> /dev/null > /dev/null
            if [ $? -eq 0 ]; then
                BRANCH=${$(git symbolic-ref HEAD 2> /dev/null)#refs/heads/}
                if [[ -n $BRANCH ]]; then
                    STATUS=$(git status --porcelain 2> /dev/null | tail -n1)
                    if [[ -n $STATUS ]]; then
                        git_color=$fg_bold[red]
                    else
                        git_color=$fg_bold[green]
                    fi
                    echo "%{$fg_bold[grey]%} :: %{$fg_bold[white]%}${BRANCH}%{${git_color}#%{$fg_bold[grey]%}"
                fi
            fi
        }
    
        PROMPT=$'%{$fg_bold[grey]%}[%{$fg_bold[$PROMPT_HOST_COLOR]%}%m %{$fg_bold[grey]%}:: %(!.%{$fg_bold[red]%}.%{$fg_bold[green]%})%n%{$fg_bold[grey]%}][%{$fg_bold[white]%}%~%{$fg_bold[grey]%}$(_developer_git)]\n[%(?,%{$fg_bold[green]%}$PROMPT_CO%{$reset_color%},%{$fg_bold[red]%}$PROMPT_CE%{$reset_color%})%{$fg_bold[grey]%}]%(!.%{$fg_bold[red]%}#.%{$fg_bold[green]%}$)%{$reset_color%} '
        RPROMPT=''
    }   
    prompt_themes=($prompt_themes developer)
    
    ## enable theme
    [[ -z $THEME ]] && THEME=compact
    prompt $THEME
    unset THEME
# }}}

# {{{ variables
    # preferences
    which nano &> /dev/null ; [ $? -eq 0 ] && export EDITOR='nano'
    which vi &> /dev/null ; [ $? -eq 0 ] && export EDITOR='vi'
    which vim &> /dev/null ; [ $? -eq 0 ] && export EDITOR='vim'
    export PAGER='less'
# }}}

# {{{ aliases
    # nano wrapping
    which nano &> /dev/null ; [ $? -eq 0 ] && alias nano='nano -w'

    # default for ls
    alias ll="${aliases[ls]:-ls} -l"

    case $OSTYPE in solaris*)
        alias zfs_rsync='rsync -aviAPh'
        alias zfs_rsync+='rsync -aviAPh --delete'
    ;; esac

    # include local aliases
    [[ -e ~/.aliases ]] && source ~/.aliases || true
# }}}