#!/usr/bin/env zsh
####
# Install configuration files into homedir
###

## bootstrap
pushd ${0:a:h}
TOPDIR="$(git rev-parse --show-toplevel)"

## helpers
task_begin()     { echo -n "[..] ${@} ...\r" }
task_done()      { echo "[OK]" && return 0 }
task_fail()      { echo "[!!]" && return 1 }
log_notice()     { echo "[II] ${@}" }
log_warning()    { echo "[WW] ${@}" }
log_error()      { echo "[EE] ${@}" }
log_hard_error() { log_error ${@} ; exit 1}

## ensure we are in ~/.dotFiles
if [[ "${TOPDIR}/" != "${HOME}/.dotFiles/" ]]; then
  task_begin "Relocating repository to ~/.dotFiles/"
  if [[ ! -d "${HOME}/.dotFiles/" ]]; then
    mv "${TOPDIR}" "${HOME}/.dotFiles" && task_done || task_fail
    TOPDIR="${HOME}/.dotFiles"
  else
    task_fail
    log_error "A directory already exists at ${HOME}/.dotFiles, aborted!"
  fi
fi

## change to TOPDIR
cd "${TOPDIR}" || log_hard_error "Failed to change into ${TOPDIR}!"

## install git hooks
if [[ ! -e ".git/hooks/pre-commit" ]] then
  task_begin "Installing git pre-commit hook"
  ln -s "${TOPDIR}/tools/.git-pre-commit" ".git/hooks/pre-commit" \
    && task_done \
    || (task_fail; log_hard_error "Failed to install git pre-commit hook")
fi
if [[ ! -e ".git/hooks/post-checkout" ]] then
  task_begin "Installing git post-checkout hook"
  ln -s "${TOPDIR}/tools/.git-post-checkout" ".git/hooks/post-checkout" \
    && task_done \
    || (task_fail; log_hard_error "Failed to install git post-checkout hook")
  task_begin "Restoring permissions"
  tools/.git-post-checkout 2> /dev/null > /dev/null
  task_done
fi

## symlink top level homedir/ to $HOME/
for entry in $(find homedir -mindepth 1 -maxdepth 1 -type f -name '.DS_Store' -o -type f -name '._*' -prune -o -print); do
  task_begin "Installing ${${(s#/#)entry}[-1]}"
    source_path=".dotFiles/${entry}"
    target_path="${HOME}/${${(s#/#)entry}[-1]}"
    if [[ ! -L "${target_path}" ]] && [[ -e "${target_path}" ]]; then
      mkdir -p "${HOME}/_dotfiles_backup"
      mv "${target_path}" "${HOME}/_dotfiles_backup/"
    elif [[ -L "${target_path}" ]]; then
      rm "${target_path}"
    fi
  ln -s "${source_path}" "${target_path}" && task_done || task_fail
done

# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2
