# dotfiles

My development setup for macOS and Ubuntu/Debian: shell, tools, editors, and agents.

## Install

Run as your normal user with `curl` installed. Linux needs `sudo`.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/rayli09/dotfiles/main/install.sh)"
exec zsh
```

[Finish setup](docs/setup.md#first-run).

## Update

```bash
chezmoi update
```

## Edit

```bash
chezmoi cd
# Edit files, then:
chezmoi diff
chezmoi apply
```

[Sandbox tools](docs/tools.md) · [Setup, package updates, and testing](docs/setup.md) · [Agent setup](docs/agents.md)
