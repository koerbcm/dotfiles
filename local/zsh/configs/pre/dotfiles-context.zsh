#!/usr/bin/env zsh

# Work/personal context can be explicitly overridden per machine.
# Example ~/.dotfiles-context.local:
#   export DOTFILES_CONTEXT=work
DOTFILES_CONTEXT="${DOTFILES_CONTEXT:-personal}"

if [[ -r "$HOME/.dotfiles-context.local" ]]; then
  source "$HOME/.dotfiles-context.local"
fi

case "${DOTFILES_CONTEXT}" in
  work|personal)
    ;;
  *)
    DOTFILES_CONTEXT="personal"
    ;;
esac

export DOTFILES_CONTEXT

_dotfiles_platform="${DOTFILES_PLATFORM:-${OS:-}}"
if [[ -z "$_dotfiles_platform" ]]; then
  case "$(uname -s 2>/dev/null | tr '[:upper:]' '[:lower:]')" in
    darwin) _dotfiles_platform="mac" ;;
    linux) _dotfiles_platform="linux" ;;
    *) _dotfiles_platform="unknown" ;;
  esac
fi

# Profile environment overlays (context/platform + optional home-local).
for _overlay in \
  "$DOTFILES/local/profiles/${DOTFILES_CONTEXT}.env.zsh" \
  "$DOTFILES/local/profiles/${_dotfiles_platform}.env.zsh" \
  "$HOME/.env.${DOTFILES_CONTEXT}.local" \
  "$HOME/.env.${_dotfiles_platform}.local"; do
  [[ -r "$_overlay" ]] && source "$_overlay"
done
unset _overlay

# Plugin policy defaults
# - K8s plugins enabled by default only on work mac.
# - AWS plugin is opt-in everywhere.
if [[ -z "${DOTFILES_ENABLE_OMZ_K8S_PLUGINS:-}" ]]; then
  if [[ "${DOTFILES_CONTEXT}" == "work" && "$_dotfiles_platform" == "mac" ]]; then
    export DOTFILES_ENABLE_OMZ_K8S_PLUGINS=1
  else
    export DOTFILES_ENABLE_OMZ_K8S_PLUGINS=0
  fi
fi

if [[ -z "${DOTFILES_ENABLE_OMZ_AWS_PLUGIN:-}" ]]; then
  export DOTFILES_ENABLE_OMZ_AWS_PLUGIN=0
fi

unset _dotfiles_platform
