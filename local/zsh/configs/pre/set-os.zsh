#!/usr/bin/env zsh

_uname_s="$(uname -s 2>/dev/null | tr '[:upper:]' '[:lower:]')"
KERNEL="$(uname -r 2>/dev/null)"
MACH="$(uname -m 2>/dev/null)"

case "$_uname_s" in
  darwin)
    OS="mac"
    DOTFILES_PLATFORM="mac"
    ;;
  linux)
    OS="linux"
    DOTFILES_PLATFORM="linux"
    if [[ -r /proc/sys/kernel/osrelease ]] && grep -qi microsoft /proc/sys/kernel/osrelease; then
      DOTFILES_PLATFORM="wsl"
    fi
    if [[ -r /etc/os-release ]]; then
      DIST="$(sed -n 's/^ID=//p' /etc/os-release | tr -d '"' | head -n1)"
      [ -n "$DIST" ] && export DIST
    fi
    ;;
  msys*|mingw*|cygwin*|windowsnt)
    OS="windows"
    DOTFILES_PLATFORM="windows"
    ;;
  *)
    OS="$_uname_s"
    DOTFILES_PLATFORM="$_uname_s"
    ;;
esac

export OS KERNEL MACH DOTFILES_PLATFORM
unset _uname_s
