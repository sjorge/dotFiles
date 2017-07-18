#!/bin/zsh
####
# Symlink some pkgsrc binaries into /usr/local/bin so
# that they priority over MacOS's build in tools.
###

PKGSRC_BIN=/opt/pkg/bin
PKGSRC_WANT=(rsync)

for tool in ${PKGSRC_WANT}; do
 local pkgsrc_path="${PKGSRC_BIN}/${tool}"
 local local_path="/usr/local/bin/${tool}"

 # skip if pkgsrc binary is not present
 [ ! -x "${pkgsrc_path}" ] && continue

 if [ ! -e "${local_path}" ] || [ -L ${local_path} ]; then
   ln -sf "${pkgsrc_path}" "${local_path}"
 fi
done

# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2
