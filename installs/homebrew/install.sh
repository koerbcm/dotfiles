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

declare -a DOTFILES_CREATED_TEMPLATE_FILES=()
declare -a DOTFILES_CREATED_TEMPLATE_DETAILS=()

create_template_if_missing() {
  local target_path="$1"
  local purpose="$2"
  local template_body="$3"

  if [[ -e "$target_path" ]]; then
    return 0
  fi

  printf "%s\n" "$template_body" > "$target_path"
  DOTFILES_CREATED_TEMPLATE_FILES+=("$target_path")
  DOTFILES_CREATED_TEMPLATE_DETAILS+=("$target_path|$purpose")
  info "created template: $target_path"
}

ensure_required_local_templates() {
  create_template_if_missing \
    "$HOME/.dotfiles-context.local" \
    "Per-machine shell context and optional plugin overrides." \
'# Untracked per-machine dotfiles context.
# Valid context values: work or personal.
export DOTFILES_CONTEXT=personal

# Optional plugin overrides (uncomment if needed):
# export DOTFILES_ENABLE_OMZ_K8S_PLUGINS=1
# export DOTFILES_ENABLE_OMZ_AWS_PLUGIN=1'

  create_template_if_missing \
    "$HOME/.gitconfig.identity.local" \
    "Git user identity for commits on this machine." \
'# Untracked per-machine git identity.
[user]
  name = Your Name
  email = you@example.com'

  create_template_if_missing \
    "$HOME/.gitconfig.machine.local" \
    "Optional machine-specific git include routing." \
'# Untracked machine-specific git include rules.
# Example: route a workspace to a work-only config.
# [includeIf "gitdir:/Users/your-user/workspace/"]
#   path = .gitconfig-work.local'

  create_template_if_missing \
    "$HOME/.localrc" \
    "Shell secrets and machine-local environment variables." \
'# Untracked local shell variables and secrets.
# Keep real tokens/passwords out of tracked dotfiles.
#
# Examples:
# export SOME_API_TOKEN="replace-me"
# export SOME_SERVICE_URL="https://example.internal"'

  chmod 600 \
    "$HOME/.dotfiles-context.local" \
    "$HOME/.gitconfig.identity.local" \
    "$HOME/.gitconfig.machine.local" \
    "$HOME/.localrc" 2>/dev/null || true
}

print_required_template_followup() {
  if [[ ${#DOTFILES_CREATED_TEMPLATE_FILES[@]} -eq 0 ]]; then
    return 0
  fi

  warn "action required: created local setup template files"
  for detail in "${DOTFILES_CREATED_TEMPLATE_DETAILS[@]}"; do
    local path="${detail%%|*}"
    local purpose="${detail#*|}"
    warn "  - $path"
    warn "    purpose: $purpose"
  done
  warn "update these files with your real values before continuing setup."
}

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

ensure_required_local_templates

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

print_required_template_followup

success "finished installer setup"
