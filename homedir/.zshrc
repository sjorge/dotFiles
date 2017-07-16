#### .zshrc
## Jorge Schrauwen <jorge@blackdot.be>
####

### history
## history file and size
HISTFILE=~/.zhistory
HISTSIZE=5000
SAVEHIST=2500

## share history between all session
setopt share_history
setopt hist_fcntl_lock
setopt inc_append_history

## only store once for repeat commands
setopt hist_ignore_dups

## skip if command starts with a space
setopt hist_ignore_space


### variables
## keep a directory stack
DIRSTACKSIZE=20

## dynamically set environment variables
mkdir -p "${ZDOTDIR:-${HOME}}/.zshrc.d/envvars/"
for fn_var in "${ZDOTDIR:-${HOME}}"/.zshrc.d/envvars/*; do
  [[ ! -f "${fn_var}" ]] || [[ "${fn_var}" =~ '\/README$' ]] && continue
  v_name="$(echo ${fn_var} | awk -F '/' '{print $NF}')"
  v_value="$(cat "${fn_var}")"

  # filter
  if [[ "${v_name}" =~ "^.*:.*:.*$" ]]; then
    [[ "${v_name}" =~ "^os:.*:*"   ]] && [[ ! "${OSTYPE}" =~ "^$(echo ${v_name} | awk -F ':' '{ print $2 }')" ]] && continue
    [[ "${v_name}" =~ "^host.:*:*" ]] && [[ ! "${HOST:r}" =~ "^$(echo ${v_name} | awk -F ':' '{ print $2 }')" ]] && continue
    v_name="$(echo ${v_name} | awk -F ':' '{ print $NF }')"
  fi

  eval "${v_name}=\"${v_value}\"; export ${v_name}"
done


### options
## dynamically (un)set options
mkdir -p "${ZDOTDIR:-${HOME}}/.zshrc.d/opts/"
for fn_opt in "${ZDOTDIR:-${HOME}}"/.zshrc.d/opts/*; do
  [[ ! -f "${fn_opt}" ]] || [[ "${fn_opt}" =~ '\/README$' ]] && continue
  opt=$(echo ${fn_opt} | awk -F '/' '{print tolower($NF)}')
  case "${opt}" in
    no_*)   unset ${opt:3} ;;
    *)      setopt ${opt}  ;;
  esac
done


### keybindings
## enable vi-mode
bindkey -v
bindkey -M viins "^r" history-incremental-search-backward
bindkey -M vicmd "^r" history-incremental-search-backward
bindkey " " magic-space # becasue I am lazy

## generic tweaks
bindkey "\e[Z" reverse-menu-complete # Shift+Tab


### cmdlets
## dynamically load extra functions/cmdlets
mkdir -p "${ZDOTDIR:-${HOME}}/.zshrc.d/cmdlets/"
for fn_cmd in "${ZDOTDIR:-${HOME}}"/.zshrc.d/cmdlets/*; do
  [ ! -f "${fn_opt}" ] || [[ "${fn_opt}" =~ '\/README$' ]] && continue
  cmd="$(echo ${fn_cmd} | awk -F '/' '{print $NF}')"
  eval "${cmd}() { source "${fn_cmd}"; ${cmd} \$@ }"
done


### aliases
## clear aliases
unalias -a

## include local aliases
[[ -e ~/.aliases ]] && source ~/.aliases || true

## dynamically load extra aliases
mkdir -p "${ZDOTDIR:-${HOME}}/.zshrc.d/aliases/"
for fn_alias in "${ZDOTDIR:-${HOME}}"/.zshrc.d/aliases/*; do
  [[ ! -f "${fn_alias}" ]] || [[ "${fn_alias}" =~ '\/README$' ]] && continue
  a_name="$(echo ${fn_alias} | awk -F '/' '{print $NF}')"
  a_value="$(cat "${fn_alias}")"

  # filter
  if [[ "${a_name}" =~ "^.*:.*:.*$" ]]; then
    [[ "${a_name}" =~ "^os:.*:*"   ]] && [[ ! "${OSTYPE}" =~ "^$(echo ${a_name} | awk -F ':' '{ print $2 }')" ]] && continue
    [[ "${a_name}" =~ "^host.:*:*" ]] && [[ ! "${HOST:r}" =~ "^$(echo ${a_name} | awk -F ':' '{ print $2 }')" ]] && continue
    a_name="$(echo ${a_name} | awk -F ':' '{ print $NF }')"
  fi

  if [[ "${a_value}" != "" ]]; then
    alias "${a_name}"="${a_value}"
  else
    unalias -m ${a_name}
  fi
done


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
        ##FIXME: use new auto wrapper
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
    ## FIXME: move me to somewhere else
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
    ## FIXME: is this still wanted?
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

# {{{ prompt
    ## FIXME: move to somewhere else
    ## drop some old ones and add newish ones inspired by https://github.com/robbyrussell/oh-my-zsh/wiki/External-themes
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

# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2
