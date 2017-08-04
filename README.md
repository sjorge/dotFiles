# dotFiles
My personal dotFiles repository, somethings will be encrypted.

## Top Level
- homedir/ :: skel directory for my homedir
- tools/   :: tools and wrapper for syncing my dotFiles

## TODO
- [X] tools
  - [X] git_setup_hook.sh
  - [X] pkgsrc_setup_preferences.sh
  - [X] homedir_setup.sh
  - [X] homedir_setup.sh file removal support
  - [ ] homedir_setup.sh file encryption support
  - [ ] git hooks auto add .gitignore for enc file parent
- [ ] .zshrc
  - [X] cleanup
  - [X] tab completion
  - [X] create .zshrc.d/ for dynamic configuration
    - [X] envvars :: setting of environment variables
    - [X] cmdlets :: autoloading of shell functions
    - [X] aliases :: autoloading of aliases
    - [X] options :: auto set/unset of zsh options
    - [X] themes  :: zsh themes
  - [X] SSH Gateway Command (cerberos replacement)
    - [X] basic support for seperate SSH environments
    - [X] shared environments
    - [X] none-agent environment
    - [X] ssh-agent environment
    - [X] gpg-agent environment
- [ ] .vimrc
  - [X] cleanup
  - [ ] add plugins

## Handy resources
- http://zsh.sourceforge.net/Doc/Release/Options.html
- http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion-Flags
