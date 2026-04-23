# Personal-machine aliases live here.
# This file is intentionally minimal by default.

export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"

if [[ -r "$HOME/workspace/tools/ansiblePersonal/scripts/ansible-aliases.zsh" ]]; then
  source "$HOME/workspace/tools/ansiblePersonal/scripts/ansible-aliases.zsh"
fi
