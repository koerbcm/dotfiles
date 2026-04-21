Goal
- Keep `oh-my-zsh` as the only active plugin manager, prune legacy shell config aggressively, and improve cross-platform/profile support for macOS + WSL/Linux with explicit context controls.

Non-goals
- Perfectly preserving every historical alias/function from legacy dotfiles in active startup.
- Migrating to a brand-new shell framework.
- Removing version managers (`rvm`, `pyenv`, `jenv`, `n`) requested to remain.

Constraints
- Keep startup stable and syntax-clean.
- Avoid destructive behavior.
- Preserve recoverability by keeping pruned legacy blocks available behind an opt-in switch.

Acceptance criteria
- `zplug` is not loaded during startup.
- `oh-my-zsh` remains active and prompt/theme still works.
- Hardcoded WSL Windows PATH entries are removed from active path logic.
- Active aliases/functions are materially slimmer and safer.
- Legacy aliases/functions can be re-enabled explicitly.
- Startup files pass `zsh -n`.

Approach
- Add explicit `DOTFILES_PLATFORM` and `DOTFILES_CONTEXT` detection/overrides.
- Keep active config small; move old heavy blocks to legacy files with opt-in loading.
- Gate plugin loading to avoid unnecessary OMZ plugins per machine.
- Add a small usage-audit utility to help decide plugin pruning with evidence.

Files / areas affected
- `local/zsh/configs/pre/set-os.zsh`
- `local/zsh/configs/pre/dotfiles-context.zsh` (new)
- `local/zshrc.local`
- `local/oh-my-zsh.zsh`
- `local/zsh/configs/post/path.zsh`
- `local/aliases.local`
- `local/zsh/configs/post/functions.zsh`
- `local/legacy/*.legacy.zsh` (new)
- `bin/omz-plugin-usage-audit` (new)

Verification plan
- Run `zsh -n` on startup/config files.
- Run `zsh -i -c 'exit'` and `zsh -l -i -c 'exit'` smoke checks.
- Sanity-check resulting diffs and list what remains uncertain.

Risks / open questions
- Some removed legacy aliases/functions may still be used rarely.
- Version manager order can still be environment-sensitive and may need minor follow-up tuning per machine.
- Plugin usage signal from shell history is approximate (completions and helper widgets are not fully visible in history).

Status
- [x] Define target architecture and pruning strategy
- [x] Implement config changes
- [x] Verify startup/syntax
- [x] Provide risky alias/function review and follow-up questions
