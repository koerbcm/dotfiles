Goal
- Make the bootstrap installer support macOS and Linux/WSL predictably by skipping Homebrew entirely on non-macOS while still setting up Node via nvm.

Non-goals
- Building a full Linux package-manager abstraction for every distro.
- Migrating all dotfile tooling away from rcm in this task.

Constraints
- Keep existing macOS Homebrew flow intact.
- On Linux/WSL, do not install or require Homebrew.
- Keep nvm state under `$HOME/.nvm`.

Acceptance criteria
- `installs/homebrew/install.sh` does not run Homebrew install/update/bundle on Linux/WSL.
- Linux/WSL path installs/loads nvm without Homebrew and installs Node majors 20/22/24.
- macOS path still applies Brewfile and installs Homebrew-managed nvm.
- Script syntax checks pass.

Approach
- Add OS detection at script start.
- Extract shared nvm loading logic to helper functions.
- Keep Homebrew operations inside a macOS-only branch.
- Add Linux/WSL nvm bootstrap using official nvm install script with `PROFILE=/dev/null`.
- Update README install section to reflect current script path and cross-platform behavior.

Files / areas affected
- `installs/homebrew/install.sh`
- `README.md`

Verification plan
- `bash -n installs/homebrew/install.sh`
- `shellcheck installs/homebrew/install.sh`
- Manual read-through to verify no Linux/WSL Homebrew commands remain on non-mac path.

Risks / open questions
- Linux hosts still need `rcup`/`rcm` installed separately unless already present.
- nvm installer download requires network access and GitHub availability.

Status
- [x] Plan baseline
- [x] Implement installer branching + nvm bootstrap changes
- [x] Update docs and verify
