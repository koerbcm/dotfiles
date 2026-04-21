Goal
- Modernize Homebrew automation by reconciling `installs/homebrew/Brewfile` and install scripts with the current dotfiles architecture, current local brew state, and maintained formulas/casks/taps.

Non-goals
- Automatically uninstalling many local packages without user sign-off.
- Perfectly preserving all historical coworker packages by default.

Constraints
- Keep changes reviewable and reversible.
- Prefer authoritative local brew signals (`brew list`, `brew info`, `brew bundle` checks).
- Preserve cross-machine usability where practical (work mac + personal mac/WSL).

Acceptance criteria
- Remove clearly obsolete/conflicting entries already known from shell migration (for example `zplug`, legacy node manager assumptions).
- Produce an auditable report of:
  - In Brewfile but not installed.
  - Installed but not in Brewfile.
  - Deprecated/disabled/outdated taps/formulas/casks.
- Add a reusable audit script to regenerate these checks.
- Update install workflow docs/messages to align with the modernized approach.

Approach
- Capture baseline from current `brew` state and existing Brewfile.
- Classify entries into: keep, remove, investigate, optional/profile-specific.
- Patch Brewfile/install scripts for high-confidence cleanup.
- Add script under `bin/` to automate future audits.
- Run syntax and brew-oriented checks, then summarize next decisions.

Files / areas affected
- `installs/homebrew/Brewfile`
- `installs/homebrew/install.sh`
- `installs/utils/lib.sh` (if needed)
- `bin/` audit helper (new)
- `docs/plans/dotfiles-brew-audit-modernization.md`

Verification plan
- `bash -n` for edited shell scripts.
- Brew audit script dry-run on local machine.
- Manual spot checks for critical tools (`brew`, `git`, `nvm`, `node`, `npm`, `kubectl`, `helm`).

Risks / open questions
- Some packages may be indirectly required (build deps/toolchains) even if not frequently used directly.
- Work-only vs personal-only package split is not fully encoded yet.

Status
- [x] Plan baseline
- [x] Collect and classify brew state
- [x] Implement high-confidence Brewfile/install cleanup
- [x] Add reusable brew audit script
- [x] Verify and summarize follow-up decisions
