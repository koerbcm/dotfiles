#!/usr/bin/env zsh

# Keep PATH deterministic and deduplicated across login/non-login shells.
typeset -gU path

_dotfiles_path_prepend_if_dir() {
  local _dir="$1"
  [[ -d "$_dir" ]] || return 0
  path=("$_dir" ${path:#"$_dir"})
}

_dotfiles_path_append_if_dir() {
  local _dir="$1"
  [[ -d "$_dir" ]] || return 0
  path=(${path:#"$_dir"} "$_dir")
}

dotfiles_normalize_path() {
  emulate -L zsh
  typeset -gU path

  local _dotfiles_platform _pnpm_home_default _dir _i
  _dotfiles_platform="${DOTFILES_PLATFORM:-${OS:-}}"

  # Drop legacy node manager path entries before rebuilding preferred order.
  path=(${path:#"$HOME/.n/bin"})
  if command -v nvm >/dev/null 2>&1; then
    path=(${path:#"$HOME/.npm-global/bin"})
  fi

  # Package-manager bins used often on interactive shells.
  _pnpm_home_default=""
  if [[ "$_dotfiles_platform" == "mac" ]]; then
    _pnpm_home_default="$HOME/Library/pnpm"
  elif [[ "$_dotfiles_platform" == "linux" || "$_dotfiles_platform" == "wsl" ]]; then
    _pnpm_home_default="$HOME/.local/share/pnpm"
  fi
  if [[ -n "${DOTFILES_PNPM_HOME:-}" ]]; then
    PNPM_HOME="${DOTFILES_PNPM_HOME}"
  elif [[ -n "$_pnpm_home_default" ]]; then
    PNPM_HOME="$_pnpm_home_default"
  fi

  local -a _path_front=(
    "$HOME/.dotfiles/bin"
    "$HOME/.bin"
    "$HOME/bin"
    "${PNPM_HOME:-}"
    "${NVM_BIN:-}"
    "$HOME/.pyenv/shims"
    "$HOME/.jenv/shims"
    "$HOME/.pyenv/bin"
    "$HOME/.jenv/bin"
  )

  # Homebrew/Linuxbrew fallback for non-login shells.
  case "$_dotfiles_platform" in
    mac)
      _path_front+=("/opt/homebrew/bin" "/opt/homebrew/sbin" "/usr/local/bin" "/usr/local/sbin")
      ;;
    linux|wsl)
      _path_front+=("/home/linuxbrew/.linuxbrew/bin" "/home/linuxbrew/.linuxbrew/sbin" "$HOME/.linuxbrew/bin" "$HOME/.linuxbrew/sbin" "/usr/local/bin" "/usr/local/sbin")
      ;;
  esac

  for (( _i=${#_path_front[@]}; _i>=1; _i-- )); do
    _dotfiles_path_prepend_if_dir "${_path_front[_i]}"
  done

  # Keep explicit system dirs present for Linux/WSL if inherited PATH is minimal.
  if [[ "$_dotfiles_platform" == "linux" || "$_dotfiles_platform" == "wsl" ]]; then
    for _dir in /usr/sbin /usr/bin /sbin /bin; do
      _dotfiles_path_append_if_dir "$_dir"
    done
  fi

  # Convenience bins that should not win precedence.
  for _dir in \
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" \
    "/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin" \
    "/Applications/VSCodium.app/Contents/Resources/app/bin" \
    "$HOME/Applications/Visual Studio Code.app/Contents/Resources/app/bin" \
    "$HOME/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin" \
    "$HOME/Applications/VSCodium.app/Contents/Resources/app/bin" \
    "$HOME/.rvm/bin"; do
    _dotfiles_path_append_if_dir "$_dir"
  done

  # If only insiders/codium command exists, preserve `code` muscle memory.
  if ! command -v code >/dev/null 2>&1; then
    if command -v code-insiders >/dev/null 2>&1; then
      alias code='code-insiders'
    elif command -v codium >/dev/null 2>&1; then
      alias code='codium'
    elif [[ "$_dotfiles_platform" == "mac" ]]; then
      code() { open -a "Visual Studio Code" "$@"; }
    fi
  fi

  export PNPM_HOME
  export PATH

  unset _dotfiles_platform _pnpm_home_default _dir _i _path_front
}

dotfiles_normalize_path
