Goal
- Migrate Node version management from `n` to `nvm` so Node selection is per-shell/per-terminal and stable across projects.

Non-goals
- Removing other version managers (`rvm`, `pyenv`, `jenv`).
- Refactoring unrelated shell/plugin behavior.

Constraints
- Keep `oh-my-zsh`.
- Keep `NVM_DIR` in home directory (`~/.nvm`) for writable, user-owned storage.
- Preserve cross-platform behavior for macOS + WSL/Linux.

Acceptance criteria
- Active shell config no longer prioritizes `~/.n/bin`.
- `nvm` is sourced from stable locations and uses `~/.nvm`.
- Project auto-switch uses `.nvmrc` / `.node-version` / `.n-node-version` per shell.
- Install bootstrap sets up `nvm`, installs latest `20`, `22`, `24`, and sets default to `24`.
- Edited shell/install files pass `zsh -n` / `bash -n` checks.

Approach
- Replace `n`-specific config with `nvm` init in post-node config.
- Remove `~/.n/bin` from PATH ordering.
- Replace `n auto` hooks with `nvm use --silent` hooks.
- Update Homebrew bootstrap script to install/configure `nvm` and provision Node majors.

Files / areas affected
- `local/zsh/configs/post/nvm.zsh`
- `local/zsh/configs/post/path.zsh`
- `local/zshrc.local`
- `local/zsh/configs/post/functions.zsh`
- `installs/homebrew/Brewfile`
- `installs/homebrew/install.sh`
- `docs/plans/dotfiles-nvm-migration.md`

Verification plan
- `zsh -n` on edited zsh files.
- `bash -n` on edited install scripts.
- Runtime checks in interactive shell: `whence -a node npm nvm`, `node -v`, `npm -v`, and marker-driven `nvm use` behavior.

Risks / open questions
- `n` remains installed on machine and can still be called manually; migration only removes active config wiring.
- First shell in a project with an uninstalled marker version may require `nvm install <version>`.

Status
- [x] Build migration plan
- [x] Implement shell/config migration
- [x] Implement bootstrap install migration
- [x] Verify and document outcomes
