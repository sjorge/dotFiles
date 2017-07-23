#!/usr/bin/env zsh
####
# Install git-hook
####

TOPDIR="$(git rev-parse --show-toplevel)"
cp "${TOPDIR}/tools/.git-pre-commit" "${TOPDIR}/.git/hooks/pre-commit"
cp "${TOPDIR}/tools/.git-post-checkout" "${TOPDIR}/.git/hooks/post-checkout"

# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2
