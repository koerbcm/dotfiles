# Dotfiles Agent Guide

## Scope
These instructions apply to this repository (`~/.dotfiles`).

## Goal
Keep behavior predictable across:
- work macOS
- personal macOS
- personal WSL/Linux

Prefer explicit local configuration files over hardcoded values in tracked files.

## Platform Rules
- macOS:
  - `installs/homebrew/install.sh` is allowed to use/install Homebrew.
  - `installs/homebrew/Brewfile` is authoritative for managed brew packages.
- Linux/WSL:
  - Do **not** install or use Homebrew via repo bootstrap.
  - `installs/homebrew/install.sh` must only handle `nvm` + Node setup on non-mac.

## Context Rules
- Context selector: `DOTFILES_CONTEXT` (`work` or `personal`).
- Set per machine in `~/.dotfiles-context.local`.
- If unset/invalid, default is `personal`.

Default plugin policy (from repo config):
- `work + mac` => `DOTFILES_ENABLE_OMZ_K8S_PLUGINS=1`
- all other combinations => `DOTFILES_ENABLE_OMZ_K8S_PLUGINS=0`
- `DOTFILES_ENABLE_OMZ_AWS_PLUGIN=0` unless explicitly enabled

## Where Things Go
- Machine context + plugin overrides:
  - `~/.dotfiles-context.local`
- Git identity (never in tracked repo files):
  - `~/.gitconfig.identity.local`
- Secrets/private tokens:
  - `~/.localrc` (or other untracked home-local files)
- Context/platform overlays (tracked):
  - `local/profiles/*.aliases.zsh`
  - `local/profiles/*.functions.zsh`
- Optional personal overlays (untracked):
  - `~/.aliases.<context>.local`
  - `~/.functions.<context>.local`
  - `~/.aliases.<platform>.local`
  - `~/.functions.<platform>.local`

## Bootstrap / Setup
Run on any host:

```bash
bash ~/.dotfiles/installs/homebrew/install.sh
env RCRC=$HOME/.dotfiles/rcrc rcup
source ~/.zshrc
```

On Linux/WSL, if `rcup` is missing, install `rcm` with distro packages (example: `apt`).

## Non-negotiables
- Do not commit secrets, tokens, passwords, or personal email identity values.
- Do not store machine-specific credentials in tracked files under `local/`.
- Keep `nvm` under `$HOME/.nvm`.
- Keep npm free of `prefix`/`globalconfig` in `~/.npmrc` when using nvm.

## Safe Verification Commands
Use these after setup or changes:

```bash
zsh -i -c 'echo CONTEXT=$DOTFILES_CONTEXT PLATFORM=$DOTFILES_PLATFORM K8S=$DOTFILES_ENABLE_OMZ_K8S_PLUGINS AWS=$DOTFILES_ENABLE_OMZ_AWS_PLUGIN'
whence -a node npm nvm
node -v
npm -v
```

## Agent Editing Guidance
- Prefer small, reviewable diffs.
- Update docs when behavior changes (`README.md`, this file).
- If a change affects platform behavior, verify both branches (`mac` and `linux/wsl`) in script logic.
- If unsure where user-specific data belongs, put it in a home-local untracked file and document it.
