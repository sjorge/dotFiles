#!env zsh
####
# Configure GPG
###

[ ! -e "${HOME}/.gnupg" ] && mkdir -p -m 0700 "${HOME}/.gnupg"
if [[ ! -e "${HOME}/.gnupg/gpg.conf" ]]; then
  cat <<"  GPGCONF" | sed 's/^ *//g' >> ${HOME}/.gnupg/gpg.conf
    no-emit-version
    no-comments
    keyid-format 0xlong
    with-fingerprint
    use-agent
    personal-cipher-preferences AES256 AES192 AES CAST5
    personal-digest-preferences SHA512 SHA384 SHA256 SHA224
    cert-digest-algo SHA512
    default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
    keyserver keys.gnupg.net
  GPGCONF
fi
if [[ ! -e "${HOME}/.gnupg/gpg-agent.conf" ]]; then
  cat <<"  GPGCONF" | sed 's/^ *//g' > ${HOME}/.gnupg/gpg-agent.conf
    enable-ssh-support
    use-standard-socket
    default-cache-ttl 600
    max-cache-ttl 7200
  GPGCONF
	echo "write-env-file ${HOME}/.gnupg/gpg-agent.env" >> ${HOME}/.gnupg/gpg-agent.conf
fi

# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2
