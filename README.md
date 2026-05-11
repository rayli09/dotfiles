# dotfiles

Personal workstation setup managed with [chezmoi](https://www.chezmoi.io/).

This repo is designed to be safe as a public GitHub repo:

- reusable shell, Git, Homebrew, and app setup lives here
- secrets stay in 1Password or local ignored files
- machine-specific values go in chezmoi's local config

## New Mac

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rayli09/dotfiles/main/install.sh)"
```

Or clone first:

```bash
git clone https://github.com/rayli09/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
./install.sh
```

## Daily Use

Preview pending changes:

```bash
chezmoi diff
```

Apply changes:

```bash
chezmoi apply
```

Edit a managed file:

```bash
chezmoi edit ~/.zshrc
chezmoi apply
```

Add an existing file:

```bash
chezmoi add ~/.zshrc
chezmoi add ~/.gitconfig
```

## 1Password

Install and sign in:

```bash
brew install --cask 1password 1password-cli
op signin
```

Templates can read from 1Password with `onepasswordRead`. Keep item paths stable, for example:

```gotemplate
{{ onepasswordRead "op://Private/GitHub/email" }}
```

## Local Machine Config

Values in `~/.config/chezmoi/chezmoi.toml` are not committed. Example:

```toml
[data]
  git_name = "Ruize Li"
  git_email = "you@example.com"
  work_email = "you@company.com"
```

