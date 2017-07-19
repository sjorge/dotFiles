#### .zshrc
## Jorge Schrauwen <jorge@blackdot.be>
####

### global helpers
typeset -A dynload_data
function dynload() {
  local s_dir=${@[1]}
  local b_flag=${@[2]:-1}
  dynload_data=()

  [[ ! -d "${s_dir}/" ]] && return

  for fn_entry in "${s_dir}"/*; do
    e_name="${${(s#/#)fn_entry}[-1]}"
    if [[ "${e_name}" =~ "^.*:.*:.*$" ]]; then  # detect filter
      e_name=(${(s#:#)e_name})
      case "${e_name[1]}" in
        host) [[ ! "${HOST:r}" =~ "^${e_name[2]}" ]] && continue ;;
        os)   [[ ! "${OSTYPE}" =~ "^${e_name[2]}" ]] && continue ;;
        *)                                              continue ;;
      esac
      e_name="${e_name[-1]}"
    fi
    if [ "${b_flag}" -eq 1 ] && [ -x "${fn_entry}" ]; then
      ## NOTE: value is the output after execution
      e_value="$("${fn_entry}")"
    elif [ "${b_flag}" -eq 1 ]; then
      ## NOTE: value is the first line of the file
      e_value="$(head -n 1 "${fn_entry}")"
    elif [ "${b_flag}" -eq 2 ]; then
      ## NOTE: value is the filepath
      e_value="${fn_entry}"
    else
      ## NOTE: default to no value
      e_value=
    fi

    dynload_data[${e_name}]="${e_value}"
  done
}


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
dynload "${ZDOTDIR:-${HOME}}/.zshrc.d/envvars"
for envvar in ${(@k)dynload_data}; do
  eval "${envvar}=\"${dynload_data[$envvar]}\"; export ${envvar}"
done


### options
## dynamically (un)set options
dynload "${ZDOTDIR:-${HOME}}/.zshrc.d/options/" 0
for opt in ${(@k)dynload_data}; do
  case "${opt}" in
    no_*)   unsetopt ${opt:3} ;;
    *)      setopt ${opt}     ;;
  esac
done


### cmdlets
## dynamically load extra functions/cmdlets
dynload "${ZDOTDIR:-${HOME}}/.zshrc.d/cmdlets" 2
for cmd in ${(@k)dynload_data}; do
  # NOTE: we do not use autoload, because need filtering
  eval "${cmd}() { source "${dynload_data[$cmd]}"; ${cmd} \$@ }"
done


### aliases
## clear aliases
unalias -a

## include local aliases
[[ -e ~/.aliases ]] && source ~/.aliases || true

## dynamically load extra aliases
dynload "${ZDOTDIR:-${HOME}}/.zshrc.d/aliases"
for alias in ${(@k)dynload_data}; do
  if [[ "${dynload_data[$alias]}" != "" ]]; then
    alias "${alias}"="${dynload_data[$alias]}"
  else
    unalias -m ${alias}
  fi
done


### colorization
## BSD compatible
[[ "${OSTYPE}" =~ "^solaris|^darwin|^freebsd|^linux" ]] && export CLICOLOR=1

## dircolors
if which -ps dircolors 2> /dev/null > /dev/null; then
  dircolor_configs=()
  dircolor_configs+=("/etc/DIR_COLORS")
  if dircolor_configs_pkgsrc=$(pkg_info -Q PKG_SYSCONFDIR coreutils 2> /dev/null); then
    dircolor_configs+=("${dircolor_configs_pkgsrc}/DIR_COLORS")
  fi
  dircolor_configs+=("~/.dir_colors")

  for dcconf in ${dircolor_configs}; do
    [ -r "${dcconf}" ] && eval $(dircolors -b "${dcconf}")
  done
  [ -z "${LS_COLORS}" ] && eval $(dircolors -b)
fi

## gnuls
ls_test_option() { $(which -ps ${2:-ls}) ${1} 2> /dev/null > /dev/null }
ls_wanted_options=("--color=auto" "--group-directories-first" "--quoting-style=literal")
for lbin in ls gls; do
  if which -ps ${lbin} 2> /dev/null > /dev/null; then
    for lopt in ${ls_wanted_options}; do
      ls_test_option ${lopt} ${lbin} && alias ${lbin}="${aliases[${lbin}]:-${lbin}} ${lopt}"
    done
  fi
done
unset ls_wanted_options
unfunction ls_test_option

## colorls (OpenBSD)
[[ "${OSTYPE}" =~ "^openbsd" ]] && [ -e /usr/local/bin/colorls ] && alias ls='/usr/local/bin/colorls -G'

## grep
grep_test_option() { echo | $(which -ps ${2:-grep}) ${1} "" >/dev/null 2> /dev/null  }
grep_wanted_options=("--color=auto" "--exclude-dir="{.bzr,.cvs,.git,.hg,.svn}"")
for gbin in grep ggrep; do
  for gopt in ${grep_wanted_options}; do
    grep_test_option ${gopt} ${gbin} && alias ${gbin}="${aliases[${gbin}]:-${gbin}} ${gopt}"
  done
done
unset grep_wanted_options
unfunction grep_test_option

## diff
diff_test_option() { echo -n | $(which -ps ${2:-diff}) ${1} - - >/dev/null 2> /dev/null  }
diff_wanted_options=("--color=auto")
for dbin in diff gdiff; do
  for dopt in ${diff_wanted_options}; do
    diff_test_option ${dopt} ${dbin} && alias ${dbin}="${aliases[${dbin}]:-${dbin}} ${dopt}"
  done
done
unset diff_wanted_options
unfunction diff_test_option


### advanced zle
## enable escaping of urls
if [[ ${ZSH_VERSION//\./} -ge 420 ]] ; then
  autoload -Uz url-quote-magic
  zle -N self-insert url-quote-magic
fi

## handle bracketed pasting
if [[ ${ZSH_VERSION//\./} -gt 511 ]] ; then
	if [[ ${TERM} == "dumb" ]]; then
		unset zle_bracketed_paste
  else
		autoload -Uz bracketed-paste-magic
		zle -N bracketed-paste bracketed-paste-magic
	fi
fi

## allow for easy sudo/pfexec
super-do-command() {
  # grab buf from history of emtpy
	[[ -z "${BUFFER}" ]] && zle up-history

	# drop sudo/pfexec
	if [[ "${BUFFER}" == pfexec\ * ]]; then
		LBUFFER="${LBUFFER#pfexec }"
	elif [[ "${BUFFER}" == sudo\ * ]]; then
		LBUFFER="${LBUFFER#sudo }"
	elif [[ "${BUFFER}" == ${EDITOR}\ * ]]; then
		LBUFFER="${LBUFFER#${EDITOR} }"
		LBUFFER="sudoedit $LBUFFER"
	elif [[ "${BUFFER}" == sudoedit\ * ]]; then
		LBUFFER="${LBUFFER#sudoedit }"
		LBUFFER="${EDITOR} $LBUFFER"
  elif [[ "${OSTYPE}" =~ "^solaris" ]]; then
		LBUFFER="pfexec $LBUFFER"
	else
		LBUFFER="sudo $LBUFFER"
	fi
}
zle -N super-do-command


### keybindings
## enable vi-mode
KEYTIMEOUT=2
bindkey -v
## vi insert mode
bindkey -M viins "^?"    backward-delete-char
bindkey -M viins "^H"    backward-delete-char
bindkey -M viins "^[[3~" delete-char # macOS Fn+Delete
## vi normal mode
bindkey -M vicmd "^?"    backward-delete-char
bindkey -M vicmd "^H"    backward-delete-char
bindkey -M vicmd "^[[3~" delete-char # macOS Fn+Delete
bindkey -M vicmd "!"     super-do-command
bindkey -M vicmd "^r"    history-incremental-search-backward

## generic tweaks
bindkey " " magic-space # becasue I am lazy
bindkey "\e[Z" reverse-menu-complete # Shift+Tab


### local customizations
## NOTE: we load zlocal BEFORE theming so any custom variables can take effect
[ -r "${ZDOTDIR:-${HOME}}/.zlocal" ] && source "${ZDOTDIR:-${HOME}}/.zlocal"


### themes
## enable theme support
autoload -U colors && colors
autoload -Uz promptinit && promptinit
PROMPT_THEME="${PROMPT_THEME:-gentoo}"
prompt_themes=()

## load themes
dynload "${ZDOTDIR:-${HOME}}/.zshrc.d/themes" 2
for pcfg in ${(@k)dynload_data}; do
  eval "prompt_${pcfg}_setup() { source "${dynload_data[$pcfg]}"  }"
  #source "${dynload_data[$pcfg]}"
  if which "prompt_${pcfg}_setup" 2> /dev/null > /dev/null; then
     prompt_themes+=("${pcfg}")
  fi
done

## enable theme
[[ -n "${prompt_themes[(r)${PROMPT_THEME}]}" ]] && prompt "${PROMPT_THEME}"
unset PROMPT_THEME


### global helpers (cleanup)
unfunction dynload

##### LEGACY CLEAN UP BELOW ######
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
    #setopt auto_menu    # show menu on 2nd <tab>
    setopt auto_list
    #setopt list_rows_first  # use row list if possible

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

    ## mosh
    compdef mosh=ssh
# }}}

# {{{ auto correction
    ## disable auto correct
    #alias cd='nocorrect cd'
    #alias cp='nocorrect cp'
    #alias gcc='nocorrect gcc'
    #alias grep='nocorrect grep'
    #alias ln='nocorrect ln'
    #alias man='nocorrect man'
    #alias mkdir='nocorrect mkdir'
    #alias mv='nocorrect mv'
    #alias rm="nocorrect ${aliases[rm]:-rm}"
    #which sshpass &> /dev/null ; [ $? -eq 0 ] && alias sshpass='nocorrect sshpass'
    
    ## disable globbing.
    #alias find='noglob find'
    #alias ftp='noglob ftp'
    #alias history='noglob history'
    #alias locate='noglob locate'
    #alias rsync='noglob rsync'
    #alias scp='noglob scp'
    #alias sftp='noglob sftp'
    #alias ssh='noglob ssh'
# }}}

# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2
