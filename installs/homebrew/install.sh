#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=/dev/null
. "$HOME/.dotfiles/installs/utils/lib.sh"

OS_NAME="$(uname -s)"
DOTFILES_INSTALL_PLATFORM="unknown"
if [[ "$OS_NAME" == "Darwin" ]]; then
  DOTFILES_INSTALL_PLATFORM="mac"
elif [[ "$OS_NAME" == "Linux" ]]; then
  if grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null; then
    DOTFILES_INSTALL_PLATFORM="wsl"
  else
    DOTFILES_INSTALL_PLATFORM="linux"
  fi
fi

info "detected platform: $DOTFILES_INSTALL_PLATFORM"

source_nvm() {
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  mkdir -p "$NVM_DIR"

  local nvm_sh=""
  local candidates=(
    "$NVM_DIR/nvm.sh"
    "/opt/homebrew/opt/nvm/nvm.sh"
    "/usr/local/opt/nvm/nvm.sh"
    "$HOME/.linuxbrew/opt/nvm/nvm.sh"
    "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"
  )

  if command -v brew >/dev/null 2>&1; then
    local brew_nvm_prefix
    brew_nvm_prefix="$(brew --prefix nvm 2>/dev/null)"
    [[ -n "$brew_nvm_prefix" ]] && candidates+=("$brew_nvm_prefix/nvm.sh")
  fi

  for nvm_sh in "${candidates[@]}"; do
    if [[ -s "$nvm_sh" ]]; then
      # shellcheck source=/dev/null
      source "$nvm_sh"
      return 0
    fi
  done

  return 1
}

install_nvm_standalone() {
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  mkdir -p "$NVM_DIR"

  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    info "installing nvm in $NVM_DIR without Homebrew"
    PROFILE=/dev/null /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh)"
  fi

  source_nvm || fail "unable to source nvm from $NVM_DIR"
}

install_nvm_with_brew() {
  info "installing nvm via Homebrew"
  brew install nvm
  source_nvm || fail "unable to source nvm after Homebrew install"
}

install_nvm_nodes() {
  if [[ -f "$HOME/.npmrc" ]] && grep -Eq '^\s*(prefix|globalconfig)\s*=' "$HOME/.npmrc"; then
    warn "$HOME/.npmrc has prefix/globalconfig set; this conflicts with nvm-managed npm"
    warn "remove those keys from $HOME/.npmrc, then run: nvm install 20 --latest-npm && nvm install 22 --latest-npm && nvm install 24 --latest-npm"
    return 0
  fi

  info "installing node majors for nvm: 20, 22, 24"
  for node_major in 20 22 24; do
    nvm install "$node_major" --latest-npm
  done

  info "setting nvm default node version to 24"
  nvm alias default 24
  nvm use default
}

if [[ "$DOTFILES_INSTALL_PLATFORM" == "mac" ]]; then
  export HOMEBREW_CASK_OPTS="--appdir=/Applications"

  info "checking for existing homebrew install"
  if ! command -v brew >/dev/null 2>&1; then
    info "existing install not found, installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    success "installed homebrew"
  fi

  if ! command -v brew >/dev/null 2>&1; then
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi
  command -v brew >/dev/null 2>&1 || fail "brew not found in PATH after installation"

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

  install_nvm_with_brew

  info "java versions/locations"
  /usr/libexec/java_home -V || true
else
  info "non-mac platform detected; skipping Homebrew install/update/Brewfile"
  if command -v brew >/dev/null 2>&1; then
    warn "brew is installed on this host but this installer will not use brew outside macOS"
  fi
  install_nvm_standalone
fi

install_nvm_nodes

if ! command -v rcup >/dev/null 2>&1; then
  if [[ "$DOTFILES_INSTALL_PLATFORM" == "linux" || "$DOTFILES_INSTALL_PLATFORM" == "wsl" ]]; then
    warn "rcup is not installed; install rcm via your distro package manager (example: sudo apt-get install -y rcm)"
  else
    warn "rcup is not installed"
  fi
fi

info "reminder: with nvm, do not set npm prefix/globalconfig in ~/.npmrc"
info "reminder: run rcup for dotfiles: env RCRC=$HOME/.dotfiles/rcrc rcup"
if [[ "$DOTFILES_INSTALL_PLATFORM" == "mac" ]]; then
  info "to auto-update brew: brew autoupdate --start --upgrade --cleanup --enable-notification"
fi

success "finished installer setup"
