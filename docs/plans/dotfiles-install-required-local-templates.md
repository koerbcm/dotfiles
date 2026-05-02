Goal
- Ensure first-run installer scaffolds required untracked local files with safe templates when missing, then clearly tells the user to fill them before continuing setup.

Non-goals
- Populate real secrets, emails, or machine-specific credentials.
- Replace `rcup` or shell-reload workflow steps.
- Enforce policy by failing installation when templates are created.

Constraints
- Keep setup idempotent and non-destructive (do not overwrite existing files).
- Keep secrets and identity data out of tracked files.
- Preserve current cross-platform installer behavior (mac uses Homebrew path, linux/wsl skips Homebrew).

Acceptance criteria
- Installer creates missing files in `$HOME` for:
  - `.dotfiles-context.local`
  - `.gitconfig.identity.local`
  - `.gitconfig.machine.local`
  - `.localrc`
- Each created file includes comments and template structure only.
- Installer prints a clear post-install summary of files it created and states they must be updated before continuing.
- Existing files are left untouched.

Approach
- Add helper functions in `installs/homebrew/install.sh` to:
  - write file content only when target does not exist
  - track created files and human-readable purpose labels
- Run scaffold step near installer completion so message appears in final handoff.
- Emit explicit warning block with per-file purpose and next-step instruction.

Files / areas affected
- `installs/homebrew/install.sh`
- `README.md`
- `docs/plans/dotfiles-install-required-local-templates.md`

Verification plan
- `bash -n installs/homebrew/install.sh` for syntax safety.
- Execute installer in isolated temp `$HOME` with mocked deps to exercise scaffold and messaging without mutating real home state.
- Confirm a second run does not recreate existing files and does not duplicate warning block.

Test plan
- Before-state:
  - temp home with none of the target files present.
- Happy path:
  - run installer path and verify all four files are created with template content.
  - verify output includes clear “update before continuing” instruction.
- Sad path:
  - precreate one or more files and verify installer preserves them unchanged.
  - rerun and verify no additional creation output for already existing files.

Monitoring plan
- For future regressions, watch installer output for:
  - missing action-required block on first-run homes.
  - accidental overwrite of pre-existing local files.

Risks / open questions
- Full installer includes network/package-manager operations; local test harness should isolate scaffold behavior to keep verification deterministic.
- The required list may evolve; keep helper code centralized in installer for easy additions.

Status
- Completed
