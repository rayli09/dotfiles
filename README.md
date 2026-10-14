# dotfiles

My source of truth for a quick dev setup on **macOS and Ubuntu/Debian Linux**:
shell, Git, runtimes, editor settings, and shared coding-agent skills. Upstream skills are pinned and fetched during setup;
only personal skills live in this repo.

## Install

Run as your normal user (Linux needs `sudo`). Install `curl` first if missing.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/rayli09/dotfiles/main/install.sh)"
exec zsh
```

macOS installs Homebrew tools and desktop apps. Linux installs CLI tools.
Both install Node, Python, Go, Bun, uv, GitHub CLI, 1Password CLI, and the
shared setup for Codex, Claude Code, Muse Code, and OpenCode. Agent apps/CLIs
and account sign-ins are separate; existing credentials are not copied.

Set your Git identity once:

```bash
chezmoi edit-config  # set data.git_name and data.git_email
chezmoi apply
gh auth login
```

## Update

```bash
chezmoi update
```

This pulls and applies dotfiles and agent skills. To update installed packages:

```bash
bash "$(chezmoi source-path)/scripts/update-macos.sh"   # macOS
bash "$(chezmoi source-path)/scripts/update-ubuntu.sh"  # Ubuntu/Debian
```

## Change something

```bash
chezmoi cd
# Edit dot_zshrc, agents/AGENTS.md, agents/personal-skills/, or the package lists.
chezmoi diff
chezmoi apply
git add -A
git commit -m "Update dev setup"
git push
```

Keep secrets in 1Password or local ignored files. Keep project-specific skills
in that project. Restart coding agents after updating their setup.

[Setup details](docs/setup.md) · [Shared agent setup](docs/agents.md)
