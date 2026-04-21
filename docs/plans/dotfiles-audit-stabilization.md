Goal
- Audit active shell startup behavior, identify enabled tools/plugins, and stabilize obvious syntax/load failures without making preference-based pruning decisions.

Non-goals
- Large-scale style refactors.
- Removing workflows that might still be intentionally used (without user confirmation).
- Replacing the shell framework stack in this pass.

Constraints
- Keep changes small and reviewable.
- Avoid destructive changes.
- Support both macOS and Linux/WSL startup behavior.
- Prefer objective fixes that reduce startup errors and random breakage.

Acceptance criteria
- Startup config parses cleanly with `zsh -n`.
- Missing optional tools do not produce startup errors in normal initialization paths.
- Cross-platform conditionals are less brittle (Homebrew/zplug/fzf guards).
- Inventory of enabled plugins/apps/program integrations is documented for pruning decisions.

Approach
- Inspect startup load order and active files.
- Patch only high-confidence issues in startup paths.
- Re-run syntax checks and startup smoke tests.
- Summarize enabled integrations and identify prune candidates.

Files / areas affected
- `zprofile`
- `local/zshrc.local`
- `local/zplug-plugins.zsh`
- `local/zsh/configs/fzf.zsh`
- `local/zsh/configs/post/path.zsh`
- `local/aliases.local`
- `local/zsh/configs/post/functions.zsh` (targeted syntax cleanup only)

Verification plan
- Run `zsh -n` across edited startup/config files.
- Run startup smoke commands (`zsh -i -c exit`, `zsh -l -i -c exit`) and inspect error output.
- Check git diff for scope sanity.

Risks / open questions
- Some aliases/functions may still be intentionally kept for rare workflows.
- Choosing between `oh-my-zsh` and `zplug` should be user-driven before major pruning.
- WSL path policy (append inherited Windows path vs curated allow-list) needs explicit preference.

Status
- [x] Audit startup files and current behavior
- [x] Apply low-risk stabilization patches
- [x] Verify with syntax + startup smoke checks
- [x] Provide full inventory, prune candidates, and questions
