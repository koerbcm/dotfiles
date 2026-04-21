# Core utility functions
# -----------------------------------------------------------------------------
killport() {
  lsof -t -i "tcp:$1" | xargs kill
}

killps() {
  ps -ef | grep "$1" | grep -v 'grep' | awk '{print $2}' | xargs kill -9
}

whereami() {
  if [[ -n "$SSH_CLIENT$SSH2_CLIENT$SSH_TTY" ]]; then
    echo ssh
    return
  fi

  local sess_src
  local sess_parent
  sess_src="$(who am i | sed -n 's/.*(\(.*\))/\1/p')"
  sess_parent="$(ps -o comm= -p "$PPID" 2>/dev/null)"

  if [[ -z "$sess_src" || "$sess_src" = :* ]]; then
    echo lcl
  elif [[ "$sess_parent" = "su" || "$sess_parent" = "sudo" ]]; then
    echo su
  else
    echo tel
  fi
}

jcurl() {
  curl "$@" | json | pygmentize -l json
}

auth-jcurl() {
  curl \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-User-Email: $1" \
    -H "X-User-Token: $2" \
    "${@:3}" | json | pygmentize -l json
}

brewup() {
  if ! command -v brew >/dev/null 2>&1; then
    echo 'brew is not installed' >&2
    return 1
  fi
  brew update --verbose && brew outdated && brew upgrade && brew cleanup
}

showpath() {
  echo "$PATH" | tr ':' '\n'
}

# Usage: extract <file>
extract() {
  if [[ ! -f "$1" ]]; then
    echo "'$1' is not a valid file"
    return 1
  fi

  case "$1" in
    *.tar.bz2) tar -jxvf "$1" ;;
    *.tar.gz) tar -zxvf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.dmg) hdiutil mount "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar -xvf "$1" ;;
    *.tbz2) tar -jxvf "$1" ;;
    *.tgz) tar -zxvf "$1" ;;
    *.zip|*.ZIP) unzip "$1" ;;
    *.pax) cat "$1" | pax -r ;;
    *.pax.Z) uncompress "$1" --stdout | pax -r ;;
    *.Z) uncompress "$1" ;;
    *)
      echo "'$1' cannot be extracted/mounted via extract()"
      return 1
      ;;
  esac
}

# Docker helpers
# -----------------------------------------------------------------------------
dkln() {
  docker logs -f "$(docker ps | grep "$1" | awk '{print $1}')"
}

dkclean() {
  docker ps --all -q -f status=exited | xargs docker rm
  docker volume ls -qf dangling=true | xargs docker volume rm
}

dkprune() {
  docker system prune -af
}

dkstats() {
  if [[ $# -eq 0 ]]; then
    docker stats --no-stream
  else
    docker stats --no-stream | grep "$1"
  fi
}

dke() {
  docker exec -it "$1" /bin/sh
}

dkstate() {
  docker inspect "$1" | jq '.[0].State'
}

# Context/debug helper
# -----------------------------------------------------------------------------
dotfiles_context() {
  echo "DOTFILES_CONTEXT=${DOTFILES_CONTEXT:-unset}"
  echo "DOTFILES_PLATFORM=${DOTFILES_PLATFORM:-unset}"
  echo "OS=${OS:-unset}"
}

# Node version auto-switch for `nvm` (per-shell, marker-driven).
autoload -Uz add-zsh-hook

typeset -g _DOTFILES_LAST_NODE_MARKER=""
typeset -g _DOTFILES_LAST_NODE_REQUESTED=""

_dotfiles_find_node_marker() {
  local _dir="$PWD"
  local _marker

  while [[ -n "$_dir" && "$_dir" != "/" ]]; do
    for _marker in .nvmrc .node-version .n-node-version; do
      if [[ -f "$_dir/$_marker" ]]; then
        print -r -- "$_dir/$_marker"
        return 0
      fi
    done
    _dir="${_dir:h}"
  done

  return 1
}

_dotfiles_read_node_requested_version() {
  local _marker_file="$1"
  [[ -n "$_marker_file" && -f "$_marker_file" ]] || return 1

  local _requested
  _requested="$(sed -n '/./{s/^[[:space:]]*//;s/[[:space:]]*$//;p;q;}' "$_marker_file" 2>/dev/null)"
  [[ -n "$_requested" ]] || return 1
  _requested="${_requested#v}"
  print -r -- "$_requested"
}

_dotfiles_nvm_auto_use() {
  [[ -o interactive ]] || return 0
  command -v nvm >/dev/null 2>&1 || return 0

  local _marker=""
  _marker="$(_dotfiles_find_node_marker 2>/dev/null)" || _marker=""

  if [[ -z "$_marker" ]]; then
    if [[ -n "$_DOTFILES_LAST_NODE_MARKER" ]]; then
      nvm use --silent default >/dev/null 2>&1 || true
    fi
    _DOTFILES_LAST_NODE_MARKER=""
    _DOTFILES_LAST_NODE_REQUESTED=""
    return 0
  fi

  local _requested=""
  _requested="$(_dotfiles_read_node_requested_version "$_marker" 2>/dev/null)" || _requested=""
  [[ -n "$_requested" ]] || return 0

  if [[ "$_marker" == "$_DOTFILES_LAST_NODE_MARKER" && "$_requested" == "$_DOTFILES_LAST_NODE_REQUESTED" ]]; then
    return 0
  fi

  _DOTFILES_LAST_NODE_MARKER="$_marker"
  _DOTFILES_LAST_NODE_REQUESTED="$_requested"
  nvm use --silent "$_requested" >/dev/null 2>&1 || true
}

add-zsh-hook chpwd _dotfiles_nvm_auto_use
_dotfiles_nvm_auto_use

# Profile and platform overlays
for _overlay in \
  "$DOTFILES/local/profiles/${DOTFILES_CONTEXT}.functions.zsh" \
  "$DOTFILES/local/profiles/${DOTFILES_PLATFORM}.functions.zsh" \
  "$HOME/.functions.${DOTFILES_CONTEXT}.local" \
  "$HOME/.functions.${DOTFILES_PLATFORM}.local"; do
  [[ -r "$_overlay" ]] && source "$_overlay"
done
unset _overlay

# Optional legacy functions (disabled by default)
if [[ "${DOTFILES_ENABLE_LEGACY_FUNCTIONS:-0}" == "1" ]] && [[ -r "$DOTFILES/local/legacy/functions.legacy.zsh" ]]; then
  source "$DOTFILES/local/legacy/functions.legacy.zsh"
fi
