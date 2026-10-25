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

On macOS, Homebrew owns system tools, Bun, uv, and desktop apps; mise owns
Node, Python, and Go. Wrangler is installed through npm after mise activation.
Homebrew may also install runtimes as dependencies of other formulae.
The shared editor extension list is `private_dot_config/vscode/extensions.txt`;
macOS and Windows bootstrap/update scripts read it for VS Code and Cursor.

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
Run `bash scripts/test-scripts.sh` for isolated command-flow checks, shared
editor-template rendering, and failure propagation. These use stub commands,
so they do not install or update packages.

## Container tests

From the checkout, run the fast Linux checks and disposable-home deployment:

```bash
docker build -f Containerfile.test -t dotfiles-check .
docker run --rm dotfiles-check
```

For a full fresh install as a normal user with sudo, repeat setup, package
updates, and runtime ownership checks in a fresh login shell:

```bash
docker build -f Containerfile.integration -t dotfiles-integration .
docker run --rm dotfiles-integration

# Test the same flow on Debian.
docker build --build-arg BASE_IMAGE=debian:bookworm \
  -f Containerfile.integration -t dotfiles-integration-debian .
docker run --rm dotfiles-integration-debian
```

The integration image defaults to Ubuntu 24.04. It snapshots the local working
tree, including unpublished changes, and redirects Git clone/pull to that
snapshot inside the container. It does not fetch the dotfiles from remote
`main`. Package and skill downloads still require network access. Each run
starts with a fresh test user; no host home or Docker socket is mounted.

`test-linux-install.sh` changes the test user's home and installs real system
packages; run it only through the integration image. Docker CLI installation
is checked, but daemon startup, system login behavior, and desktop applications
require a VM or native machine. Rendering macOS templates on Linux verifies
file contents only. Native macOS CI applies and checks macOS preferences.
CI also runs the Linux installation flow on Ubuntu 24.04 and Debian Bookworm.

## Windows

Existing Windows scripts remain available, but the shared symlink-based agent
setup is currently supported only on macOS and Linux. Use `install.ps1` and
`scripts/smoke-windows.ps1` for the existing Windows tooling.
