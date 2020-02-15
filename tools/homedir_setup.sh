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
  [[ -L ".git/hooks/pre-commit" ]] && rm ".git/hooks/pre-commit"
  ln -s "${TOPDIR}/tools/.git-pre-commit" ".git/hooks/pre-commit" \
    && task_done \
    || (task_fail; log_hard_error "Failed to install git pre-commit hook")
fi
if [[ ! -e ".git/hooks/post-checkout" ]] then
  task_begin "Installing git post-checkout hook"
  [[ -L ".git/hooks/post-checkout" ]] && rm ".git/hooks/post-checkout"
  ln -s "${TOPDIR}/tools/.git-post-checkout" ".git/hooks/post-checkout" \
    && task_done \
    || (task_fail; log_hard_error "Failed to install git post-checkout hook")
fi

## update repository
task_begin "Updating master branch"
git fetch -a 2> /dev/null > /dev/null && task_done || task_fail
task_begin "Restore permissions"
${TOPDIR}/tools/.git-post-checkout 2> /dev/null > /dev/null && task_done || task_fail

## detach from master if not the case
branch_name="$(hostname -s)-${USER}"
if [[ "$(git rev-parse --abbrev-ref HEAD)" != "${branch_name}" ]]; then
  task_begin "Creating branch ${branch_name}"
  if git checkout ${branch_name} 2> /dev/null > /dev/null; then
    task_done
  else
    if git checkout -b ${branch_name} 2> /dev/null > /dev/null; then
      task_done
    else
      task_fail
      exit 1
    fi
  fi
fi

## merging master
task_begin "Merging changes from master"
if ! git merge --strategy-option=theirs origin/master 2> /dev/null > /dev/null; then
  task_fail
  log_hard_error "Failed to merge master into detached branch! Please resolve the issue first."
fi
task_done

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

## decrypt
if [[ ! -r "${HOME}/.dotFiles.key" ]]; then
  log_warning "Decryption skipped, missing ~/.dotFiles.key!"
else
  if ! which -ps openssl 2> /dev/null > /dev/null; then
    log_warning "Decryption skipped, could not locate openssl!"
  else
    for entry in $(find "${TOPDIR}" -type f -name "*.enc" -print); do
      task_begin "Decrypting ${entry[(${#TOPDIR}+2),-1]}"
      if cp -p "${entry}" "${entry[1,-5]}" 2> /dev/null > /dev/null; then
        openssl enc -kfile "${HOME}/.dotFiles.key" -d -a -aes-256-cbc -md md5 -in "${entry}" -out "${entry[1,-5]}" && task_done || task_fail
      else
        task_fail
      fi
    done
  fi
fi

# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2
