# Setup details

## Requirements

macOS uses Homebrew. Linux supports apt-based Ubuntu/Debian, with a normal user
and `sudo`; other distributions are not supported by the installer. For a new
root-only server, run `scripts/bootstrap-root.sh <username>` first, then sign
in as that user. The bootstrap installs substantial dev tooling; rerunning it
also updates the package set.

The default chezmoi checkout is `~/.local/share/chezmoi`. Use `chezmoi cd` to
edit the actual source. A separate Git clone is useful for development, but
running its installer still uses the configured chezmoi checkout.

Runtime versions live in `private_dot_config/mise/config.toml`; package lists
live in `Brewfile.macos` and `packages/ubuntu.sh`. Sign in to 1Password with
`op signin`. Local Git identity and machine values live in
`~/.config/chezmoi/chezmoi.toml`; these are not committed.

## Optional macOS preferences

From the checkout:

```bash
bash scripts/macos-defaults.sh --dry-run
bash scripts/macos-defaults.sh
bash scripts/assert-macos-preferences.sh
```

`export-macos-preferences.sh` saves review data in an ignored directory.

## Check your setup

```bash
bash "$(chezmoi source-path)/scripts/smoke.sh"
```

For changes to this repo, run `bash scripts/check.sh` (needs shellcheck) and
`bash scripts/test-chezmoi.sh` (needs chezmoi). The latter deploys into disposable
homes and checks Linux/macOS rendering, agent links, and repeat application.
A disposable-home check is not a full fresh-machine package-install test.

## Windows

Existing Windows scripts remain available, but the shared symlink-based agent
setup is currently supported only on macOS and Linux. Use `install.ps1` and
`scripts/smoke-windows.ps1` for the existing Windows tooling.
