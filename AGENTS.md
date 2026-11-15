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
- Run `bash scripts/verify.sh` before publishing; it selects the suites the
  changed paths need, and `--plan` prints them without running. `test-chezmoi.sh`
  deploys into disposable destinations; never apply the full configuration to
  the developer's home as a test. Container integration and coverage limits live
  in `docs/setup.md`; `scripts/test-linux-install.sh` runs only in its image.
- Whenever you change this repository, run the relevant checks, commit your
  changes, and push to the remote before finishing the task. Include only the
  task's changes in the commit and preserve unrelated local edits.

## Agent goals

Goal behavior is owned by `agents/AGENTS.md`, deployed to `~/.agents/AGENTS.md`
and inherited by Codex, Claude Code, Muse Code, and OpenCode. That file decides
when to set a goal and what closing one requires.

For dotfiles work, a goal names its proof: `bash scripts/verify.sh` passes, the
task's files are clean in `git status`, and the commit is pushed.
