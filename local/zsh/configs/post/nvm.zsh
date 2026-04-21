[[ -n "${DOTFILES_NVM_INIT_DONE:-}" ]] && return 0
export DOTFILES_NVM_INIT_DONE=1

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

_dotfiles_nvm_candidates=(
  "$NVM_DIR/nvm.sh"
  "/opt/homebrew/opt/nvm/nvm.sh"
  "/usr/local/opt/nvm/nvm.sh"
  "$HOME/.linuxbrew/opt/nvm/nvm.sh"
  "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"
)

if command -v brew >/dev/null 2>&1; then
  _dotfiles_brew_nvm_prefix="$(brew --prefix nvm 2>/dev/null)"
  [[ -n "$_dotfiles_brew_nvm_prefix" ]] && _dotfiles_nvm_candidates+=("$_dotfiles_brew_nvm_prefix/nvm.sh")
fi

for _dotfiles_nvm_sh in "${_dotfiles_nvm_candidates[@]}"; do
  if [[ -s "$_dotfiles_nvm_sh" ]]; then
    source "$_dotfiles_nvm_sh"
    break
  fi
done

# Optional completion scripts (Homebrew nvm or local install).
if [[ -o interactive ]]; then
  _dotfiles_nvm_completion_candidates=(
    "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
    "/usr/local/opt/nvm/etc/bash_completion.d/nvm"
    "$HOME/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm"
    "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm"
    "$NVM_DIR/bash_completion"
  )
  for _dotfiles_nvm_completion in "${_dotfiles_nvm_completion_candidates[@]}"; do
    if [[ -s "$_dotfiles_nvm_completion" ]]; then
      source "$_dotfiles_nvm_completion"
      break
    fi
  done
fi

if command -v nvm >/dev/null 2>&1; then
  nvm use --silent default >/dev/null 2>&1 || true
fi

unset _dotfiles_nvm_sh _dotfiles_nvm_candidates _dotfiles_brew_nvm_prefix
unset _dotfiles_nvm_completion _dotfiles_nvm_completion_candidates
