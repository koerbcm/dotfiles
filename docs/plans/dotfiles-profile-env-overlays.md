Goal
- Move context/platform `export` values out of `*.aliases.zsh` into explicitly named env overlay files while preserving current shell behavior.

Non-goals
- Redesign the overall shell init flow.
- Change alias/function overlay precedence.
- Introduce machine-specific secrets into tracked files.

Constraints
- Keep diffs small and reviewable.
- Preserve existing defaults for `DOTFILES_CONTEXT` and plugin policy.
- Keep optional untracked overlays supported.

Acceptance criteria
- Profile env overlays are loaded from clearly named files.
- Existing exports from `work.aliases.zsh` and `personal.aliases.zsh` still take effect.
- Alias/function overlays continue to load as before.
- Docs describe where env exports should live.

Approach
- Add env overlay loading in `local/zsh/configs/pre/dotfiles-context.zsh`.
- Create `local/profiles/work.env.zsh` and `local/profiles/personal.env.zsh`.
- Remove moved exports from alias profile files.
- Update `local/profiles/README.md`, `README.md`, and `AGENTS.md`.

Files / areas affected
- `local/zsh/configs/pre/dotfiles-context.zsh`
- `local/profiles/work.env.zsh`
- `local/profiles/personal.env.zsh`
- `local/profiles/work.aliases.zsh`
- `local/profiles/personal.aliases.zsh`
- `local/profiles/README.md`
- `README.md`
- `AGENTS.md`

Verification plan
- `zsh -n local/zsh/configs/pre/dotfiles-context.zsh`
- `zsh -n local/profiles/work.env.zsh local/profiles/personal.env.zsh`
- `zsh -i -c 'echo GH_HOST=$GH_HOST SSH_AUTH_SOCK=$SSH_AUTH_SOCK CONTEXT=$DOTFILES_CONTEXT PLATFORM=$DOTFILES_PLATFORM'`

Risks / open questions
- `zsh` pre-config load order may vary if shell glob order is changed externally.
- Home-local env overlays (`~/.env.*.local`) are new; users may need a short heads-up.

Status
- Completed
