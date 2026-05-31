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

## New Linux Dev Server

If you are starting from a root login, create the daily user first:

```bash
curl -fsSL https://raw.githubusercontent.com/rayli09/dotfiles/main/scripts/bootstrap-root.sh | bash -s ruize
su - ruize
```

Then bootstrap the dev environment:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/rayli09/dotfiles/main/install.sh)"
```

Linux setup installs CLI/server tooling only. macOS setup installs Homebrew packages and GUI apps from `Brewfile.macos`.

Update Ubuntu packages and user-space tooling:

```bash
scripts/update-ubuntu.sh
```

## New Windows Dev Box

Run PowerShell as your normal user:

```powershell
irm https://raw.githubusercontent.com/rayli09/dotfiles/main/install.ps1 | iex
```

Windows setup uses `winget` for native apps and tools, then installs `wrangler@latest` with npm.

Update Windows packages and user-space tooling:

```powershell
.\scripts\update-windows.ps1
```

## Runtime Tooling

Node, Python, and Go are managed by mise through `~/.config/mise/config.toml` and default to latest. Bun and uv are installed directly from their official installers on Ubuntu, and through Homebrew/winget on desktop platforms. Wrangler is installed globally as `wrangler@latest` for convenience, while Cloudflare still recommends project-local Wrangler versions for team projects.

Run a quick check:

```bash
scripts/smoke.sh
```

On Windows:

```powershell
.\scripts\smoke-windows.ps1
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

macOS installs the 1Password app and CLI through Homebrew. Ubuntu installs the `op` CLI through 1Password's apt repository.

Sign in:

```bash
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
