#!env zsh
####
# Symlink some pkgsrc binaries into /usr/local/bin so
# that they priority over MacOS's build in tools.
###

typeset -A PKGSRC_WANT

LOCAL_PATH="/usr/local/bin"
PKGSRC_PATH="/opt/pkg/bin"
PKGSRC_WANT[zsh]=
PKGSRC_WANT[ssh]=
PKGSRC_WANT[ssh-add]=
PKGSRC_WANT[ssh-agent]=
PKGSRC_WANT[ssh-keygen]=
PKGSRC_WANT[ssh-keyscan]=
PKGSRC_WANT[rsync]=
PKGSRC_WANT[git]=
PKGSRC_WANT[bunzip2]=
PKGSRC_WANT[bzip2]=
PKGSRC_WANT[bzip2recover]=
PKGSRC_WANT[gunzip]=
PKGSRC_WANT[gzip]=
PKGSRC_WANT[unzip]=
PKGSRC_WANT[unzipsfx]=
PKGSRC_WANT[zip]=
PKGSRC_WANT[zipcloak]=
PKGSRC_WANT[zipcmp]=
PKGSRC_WANT[zipdetails]=
PKGSRC_WANT[zipgrep]=
PKGSRC_WANT[zipinfo]=
PKGSRC_WANT[zipmerge]=
PKGSRC_WANT[zipnote]=
PKGSRC_WANT[zipsplit]=
PKGSRC_WANT[ziptool]=
PKGSRC_WANT[diff]=gdiff
PKGSRC_WANT[vim]=

for bin in ${(@k)PKGSRC_WANT}; do
 [ ! -n "${PKGSRC_WANT[${bin}]}" ] && PKGSRC_WANT[${bin}]=${bin}
 local pkgsrc_bin="${PKGSRC_PATH}/${PKGSRC_WANT[${bin}]}"
 local local_bin="${LOCAL_PATH}/${bin}"

 # skip if pkgsrc binary is not present
 if [ ! -x "${pkgsrc_bin}" ]; then
   [ -L "${local_bin}" ] && rm "${local_bin}"
   continue
 fi

 if [ ! -e "${local_bin}" ] || [ -L "${local_bin}" ]; then
   ln -sf "${pkgsrc_bin}" "${local_bin}"
 fi
done

# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2
