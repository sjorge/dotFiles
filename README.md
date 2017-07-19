# dotFiles
My personal dotFiles repository, somethings will be encrypted.

## Top Level
- homedir/ :: skel directory for my homedir
- tools/   :: tools and wrapper for syncing my dotFiles

## TODO
- [X] tools
  - [X] git_setup_hook.sh
  - [X] pkgsrc_setup_preferences.sh
  - [X] homedir_sync.sh
  - [X] homedir_sync.sh file removal support
  - [ ] homedir_sync.sh file encryption support
- [ ] .zshrc
  - [ ] cleanup
  - [ ] configure LS_COLORS to match macOS ls colorization
  - [X] create .zshrc.d/ for dynamic configuration
    - [X] envvars :: setting of environment variables
    - [X] cmdlets :: autoloading of shell functions
    - [X] aliases :: autoloading of aliases
    - [X] options :: auto set/unset of zsh options
    - [X] themes  :: zsh themes
      - [ ] expand dual theme with git (https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/git.zsh) and vi mode (http://zshwiki.org/home/zle/vi-mode) indicators
  - [ ] cerberus replacement using cmdlet
    - [ ] wrapper for ssh/scp/...
    - [ ] add ``site`` support (symlink default -> prefered site)
    - [ ] ``site`` should have custom knownhosts, ssh_config, ...
    - [ ] ``site`` easy agent -> none, ssh-agent-(shared), gpg-agent(-shared)
- [ ] .vimrc
  - [X] cleanup
  - [ ] add plugins

## Handy resources
- http://zsh.sourceforge.net/Doc/Release/Options.html
- http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion-Flags
