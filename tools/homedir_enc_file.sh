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

## change to TOPDIR
cd "${TOPDIR}" || log_hard_error "Failed to change into ${TOPDIR}!"

## preflight checks
[[ ! -n "${1:-}" ]] && log_hard_error "Usage: homedir_enc_file.sh relative/file/path.ext"
[[ ! -f "${TOPDIR}/${1}" ]] && log_hard_error "The file ${TOPDIR}/${0} does not exist!"
[[ ! -r "${HOME}/.dotFiles.key" ]] && log_hard_error "Missing encryption secret, please create ~/.dotFiles.key!"
which -ps openssl 2> /dev/null > /dev/null || log_hard_error "Please install openssl!"

## check encryption key
task_begin "Ensure ${1} is in .gitignore"
if ! grep "^${1}\$" "${TOPDIR}/.gitignore" 2> /dev/null > /dev/null; then
  echo "${1}" >> "${TOPDIR}/.gitignore"
  task_done
else
  task_done
fi

## encrypt file
task_begin "Encrypting ${1}"
openssl enc -kfile "${HOME}/.dotFiles.key" -a -aes-256-cbc -md md5 -in "${TOPDIR}/${1}" -out "${TOPDIR}/${1}.enc" && \
  task_done || \
  task_fail

# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2
