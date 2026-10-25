# Dotfiles

Personal macOS and Ubuntu/Debian development setup, managed with chezmoi.
This repository owns portable shell/Git/editor settings and shared personal
agent defaults and skills. Credentials, sessions, provider settings, and
project-owned skills remain outside this public repository.

- `install.sh` installs chezmoi, applies dotfiles, and runs the OS bootstrap.
- `mise.toml`, `mise.lock`, and `.mise/locks/` own shared tools; generate locks
  with the pinned mise release, never by hand. `mise-bootstrap.env` pins mise.
  Read `docs/tools.md` for sandbox setup, updates, and verification.
- `Brewfile.macos` and `packages/ubuntu.sh` own system package lists; shared
  runtimes are installed through the portable tools entrypoint.
- `agents/AGENTS.md` and `agents/personal-skills/` own tracked guidance and
  custom skill sources.
- `skills-lock.json` owns pinned upstream/custom selections. The pinned Skills
  CLI restores ignored `agents/runtime/`; chezmoi owns only discovery links.
  Read `docs/agents.md` before catalog changes; run `bash scripts/test-skills.sh`.
- `.chezmoiignore` excludes repository-only files and platform-specific targets.
- Keep README focused on setup, update, and edit; put details in `docs/setup.md`.
- Run `bash scripts/check.sh`; run `bash scripts/test-chezmoi.sh` for deployment
  or template changes. Both use disposable destinations; never apply the full
  configuration to the developer's home as a test.
- Run `bash scripts/test-scripts.sh` for script behavior changes. Container
  integration commands and coverage limits live in `docs/setup.md`; run
  `scripts/test-linux-install.sh` only in its disposable integration image.
- Preserve local uncommitted edits; validate changes before publishing.
- Whenever you change this repository, run the relevant checks, commit your
  changes, and push to the remote before finishing the task. Include only the
  task's changes in the commit; preserve unrelated local edits.
