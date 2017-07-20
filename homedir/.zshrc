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

  for fn_entry in "${s_dir}"/*(.N); do
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


### tab completion
## enable completion
zmodload -i zsh/complist
autoload -U compinit && compinit

## enable caching
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zcache

## various tweaks
zstyle '*' single-ignored show
# NOTE: menu default
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' list-colors ''
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
# NOTE: make foo//bar -> foo/bar
zstyle ':completion:*' squeeze-slashes true
# NOTE: case sensitive matching
zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'
# NOTE: case insensitive matching
#zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

## dynamically load extra compdefs
fpath+=("${ZDOTDIR:-${HOME}}/.zshrc.d/compdef")
dynload "${ZDOTDIR:-${HOME}}/.zshrc.d/compdef" 2
for comp in ${(@k)dynload_data}; do
  if [[ "${comp}" =~ "^_" ]]; then
    autoload -Uz "${comp}"
  else
    source "${dynload_data[$comp]}"
  fi
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
if which -p dircolors 2> /dev/null > /dev/null; then
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
ls_test_option() { $(which -p ${2:-ls}) ${1} 2> /dev/null > /dev/null }
ls_wanted_options=("--color=auto" "--group-directories-first" "--quoting-style=literal")
for lbin in ls gls; do
  if which -p ${lbin} 2> /dev/null > /dev/null; then
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
grep_test_option() { echo | $(which -p ${2:-grep}) ${1} "" >/dev/null 2> /dev/null  }
grep_wanted_options=("--color=auto" "--exclude-dir="{.bzr,CVS,.git,.hg,.svn}"")
for gbin in grep ggrep; do
  if which -p ${gbin} 2> /dev/null > /dev/null; then
    for gopt in ${grep_wanted_options}; do
      grep_test_option ${gopt} ${gbin} && alias ${gbin}="${aliases[${gbin}]:-${gbin}} ${gopt}"
    done
  fi
done
unset grep_wanted_options
unfunction grep_test_option

## diff
diff_test_option() { echo -n | $(which -p ${2:-diff}) ${1} - - >/dev/null 2> /dev/null  }
diff_wanted_options=("--color=auto")
for dbin in diff gdiff; do
  if which -p ${dbin} 2> /dev/null > /dev/null; then
    for dopt in ${diff_wanted_options}; do
      diff_test_option ${dopt} ${dbin} && alias ${dbin}="${aliases[${dbin}]:-${dbin}} ${dopt}"
    done
  fi
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

## zle hooks
zle-keymap-select() {
  # NOTE: trigger a prompt reset on vi-mode change
  () { return $__prompt_status }
  zle reset-prompt
}
zle-line-init() {
  # NOTE: store current exit code
  typeset -g __prompt_status="$?"
}
zle -N zle-keymap-select
zle -N zle-line-init

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
  if which "prompt_${pcfg}_setup" 2> /dev/null > /dev/null; then
     prompt_themes+=("${pcfg}")
  fi
done

## enable theme
[[ -n "${prompt_themes[(r)${PROMPT_THEME}]}" ]] && prompt "${PROMPT_THEME}"
unset PROMPT_THEME


### global helpers (cleanup)
unfunction dynload

# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2
