# dotFiles
My personal dotFiles repository, somethings will be encrypted.

## Top Level
- homedir/ :: skel directory for my homedir
- tools/   :: tools and wrapper for syncing my dotFiles

## TODO
- [ ] reimplement ``cerberus`` using ``site_ssh``
  - [ ] basic ssh site switching cmdlet
  - [ ] add support for agent -> none, standalone, gpg, gpg-shared
- [ ] .zshrc
  - [ ] use .zshrc.d (better path?)
  - [ ] create pluggable cmdlets in .zshrc.d/cmdlet/NAME
  - [ ] move themes to .zshrc.d/theme/NAME
  - [ ] move host specfic stuff to .zshrc.d/host/UNAME
  - [ ] cleanup of auto completion
  - [ ] improved pkgsrc support for OSX
- [ ] write sync script

## Handy resources
- http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion-Flags
