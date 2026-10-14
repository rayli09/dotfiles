# Dotfiles

Personal macOS and Ubuntu/Debian development setup, managed with chezmoi.
This repository owns portable shell/Git/editor settings and shared personal
agent defaults and skills. Credentials, sessions, provider settings, and
project-owned skills remain outside this public repository.

- `install.sh` installs chezmoi, applies dotfiles, and runs the OS bootstrap.
- `Brewfile.macos` and `packages/ubuntu.sh` own platform package lists.
- `agents/` owns shared defaults and personal/customized skills only.
- `.chezmoiexternal.toml` owns upstream skill paths, immutable revisions, and
  archive checksums. Preserve contents when changing deployment; avoid vendoring.
- `.chezmoiignore` excludes repository-only files and platform-specific targets.
- Keep README focused on setup, update, and edit; put details in `docs/setup.md`.
- Run `bash scripts/check.sh`; run `bash scripts/test-chezmoi.sh` for deployment
  or template changes. Both use disposable destinations; never apply the full
  configuration to the developer's home as a test.
- Preserve local uncommitted edits; validate changes before publishing.
