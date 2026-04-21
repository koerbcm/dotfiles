#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=/dev/null
. "$HOME/.dotfiles/installs/utils/lib.sh"

if [[ "$(uname -s)" == "Darwin" ]]; then
  export HOMEBREW_CASK_OPTS="--appdir=/Applications"
fi

info "checking for existing homebrew install"
if ! command -v brew >/dev/null 2>&1; then
  info "existing install not found, installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  success "installed homebrew"
fi

info "updating homebrew"
brew update
success "updated homebrew"

info "installing homebrew bundle"
brew install homebrew/bundle/brew-bundle
success "installed homebrew bundle"

info "installing rcm for dotfiles operations"
brew install rcm
success "installed rcm"

info "installing Brewfile packages (this may take a while)"
brew bundle --file "$HOME/.dotfiles/installs/homebrew/Brewfile"
success "installed Brewfile packages"

if brew list --formula node >/dev/null 2>&1; then
  info "uninstalling brew node formula (nvm manages node/npm versions)"
  brew uninstall node --ignore-dependencies
fi

if [[ -f "$HOME/.npmrc" ]] && grep -Eq '^\s*(prefix|globalconfig)\s*=' "$HOME/.npmrc"; then
  warn "$HOME/.npmrc has prefix/globalconfig set; this conflicts with nvm-managed npm"
  warn "remove those keys from $HOME/.npmrc, then run: nvm install 20 --latest-npm && nvm install 22 --latest-npm && nvm install 24 --latest-npm"
else
  info "configuring nvm in home directory"
  export NVM_DIR="$HOME/.nvm"
  mkdir -p "$NVM_DIR"

  NVM_SH="$(brew --prefix nvm)/nvm.sh"
  if [[ -s "$NVM_SH" ]]; then
    # shellcheck source=/dev/null
    source "$NVM_SH"
  else
    fail "unable to find nvm.sh at $NVM_SH"
  fi

  info "installing node majors for nvm: 20, 22, 24"
  for node_major in 20 22 24; do
    nvm install "$node_major" --latest-npm
  done

  info "setting nvm default node version to 24"
  nvm alias default 24
  nvm use default
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  info "java versions/locations"
  /usr/libexec/java_home -V || true
fi

info "reminder: with nvm, do not set npm prefix/globalconfig in ~/.npmrc"
info "reminder: run rcup for dotfiles: env RCRC=$HOME/.dotfiles/rcrc rcup"
info "to auto-update brew: brew autoupdate --start --upgrade --cleanup --enable-notification"

success "finished homebrew setup"
