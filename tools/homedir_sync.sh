#!/bin/zsh
####
# Copy dotfiles to homedirectory
###

## figure out repository base
TOPDIR="$(git rev-parse --show-toplevel)"
DIFFBIN="diff"
DIFFARG="-u"
FORCE=0

## parse args
while getopts ":f" opt ${@}; do
  case $opt in
    f) FORCE=1 ;;
  esac
done

## detect gnu diff
if which -ps gdiff 2> /dev/null > /dev/null; then
  DIFFBIN="gdiff"
  DIFFARG="--color=auto -u"
fi

## create directories
echo "[..] Creating Directories ..."
pushd "${TOPDIR}/homedir"
for dir in $(find . -mindepth 1 -type f -name '.DS_Store' -prune -o -name '*.enc' -prune -o -type d -print); do
  dir=${dir[3,-1]}
  pushd "${HOME}"
  echo -ne "[>>]   ${dir}\r"
  if [ ! -d "${dir}" ]; then
    mkdir -p "${dir}" && echo -e "[++]" || echo -e "[!!]"
  else
    echo -e "[==]"
  fi
  popd
done
popd

## compare files
echo "[..] Copying files ..."
pushd "${TOPDIR}/homedir"
for file in $(find . -mindepth 1 -type f -name '.DS_Store' -prune -o -name '*.enc' -prune -o -type f -print); do
  file=${file[3,-1]}
  pushd "${HOME}"
  echo -ne "[>>]   ${file}\r"
  if [ ! -e "${file}" ]; then
    cp -p "${TOPDIR}/homedir/${file}" "${file}" && echo -e "[++]" || echo -e "[!!]"
  else
    if ${DIFFBIN} "${file}" "${TOPDIR}/homedir/${file}" 2> /dev/null > /dev/null; then
      echo -e "[==]"
    elif [ "${FORCE}" -gt 0 ]; then
      cp -p "${TOPDIR}/homedir/${file}" "${file}" && echo -e "[++]" || echo -e "[!!]"
    else
      echo -e "[??]"
      eval ${DIFFBIN} ${DIFFARG} "${file}" "${TOPDIR}/homedir/${file}"
      read -q "do_replace?Accept changes? (y/N) " ; echo
      [[ "${do_replace}" == "y" ]] && cp -p "${TOPDIR}/homedir/${file}" "${file}"
    fi
  fi
  popd
done
popd

## decrypt encrypted files
echo "[..] Decrypting files ..."
echo "[??]   TODO" ## TODO

## applying permissions
echo "[..] Applying permissions ..."
source "${TOPDIR}/.permissions"
pushd "${HOME}"
for file in ${(o)${(@k)PERM}}; do
  rfile=$(echo ${file} | grep "homedir/" | sed 's#homedir/##g;s#\.enc$##g')
  rmode=${PERM[${file}]}
  [ "$rmode" -ge 100000 ] && rmode=${rmode[-4,-1]}
  if [ -n "${rfile}" ]; then
    echo -n "[>>]  ${(Q)rfile}\r"
    chmod ${rmode} "${(Q)rfile}" 2> /dev/null > /dev/null && echo -e "[++]" || echo -e "[!!]"
  fi
done
popd

# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2
