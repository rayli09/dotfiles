# Setup details

## First run

The installer sets up shell tools, runtimes, editor settings, and shared agent
instructions and skills. macOS also installs desktop apps. Install agent
apps/CLIs separately and sign in to the services you use.

Set your Git identity once:

```bash
chezmoi edit-config  # set data.git_name and data.git_email
chezmoi apply
gh auth login
```

Sign in to 1Password with `op signin`. Keep secrets in 1Password or local
ignored files; credentials are not copied by this repository.

## Requirements

macOS uses Homebrew. Linux supports apt-based Ubuntu/Debian, with a normal user
and `sudo`; other distributions are not supported by the installer. For a new
root-only server, run `scripts/bootstrap-root.sh <username>` first, then sign
in as that user. The bootstrap installs substantial dev tooling; rerunning it
also updates the package set.

The default chezmoi checkout is `~/.local/share/chezmoi`. Use `chezmoi cd` to
edit the actual source. A separate Git clone is useful for development, but
running its installer still uses the configured chezmoi checkout.

Shared runtime and quality-tool pins live in `mise.toml` and `mise.lock`; the portable
installer is described in [tools](tools.md). System package lists live in
`Brewfile.macos` and `packages/ubuntu.sh`. Local Git identity and machine values
live in `~/.config/chezmoi/chezmoi.toml`; these are not committed.

Homebrew/apt own system tools and desktop apps. Mise owns
Node/npm, Bun, pnpm, Python/uv, Go, and quality tools under
`~/.local/share/dotfiles-tools`. Zsh activates that installation when present.
Wrangler is installed through the shared npm. System package managers may
also install runtimes as dependencies of other packages.
The shared editor extension list is `private_dot_config/vscode/extensions.txt`;
macOS bootstrap/update scripts read it for VS Code and Cursor.

### tmux plugins

The tmux configuration is synced, but its plugins are installed separately.
On a new machine, install the tmux plugin manager once:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Start tmux, then press `Ctrl-b`, release it, and press `Shift-i` to install
the plugins listed in `~/.tmux.conf`. Repeat that shortcut after adding a plugin.

## Updating packages

`chezmoi update` pulls and applies dotfiles and agent skills. Update installed
packages and reapply the shared tool pins separately:

```bash
bash "$(chezmoi source-path)/scripts/update-macos.sh"   # macOS
bash "$(chezmoi source-path)/scripts/update-ubuntu.sh"  # Ubuntu/Debian
```

## Editing

Run `chezmoi cd` to enter the source checkout. Edit `dot_zshrc`,
`agents/AGENTS.md`, `agents/personal-skills/`, or the package lists, then run
`chezmoi diff` and `chezmoi apply`. Commit and push the intended changes.
Keep project-specific skills in their projects. Restart coding agents after
updating their setup.

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

For changes to this repo, run `bash scripts/check.sh` (needs shellcheck), then
`test-chezmoi.sh` (needs chezmoi) for deployment or template changes and
`test-scripts.sh` for script changes. Those suites use stub commands and
disposable homes, so they do not install packages or touch your real dotfiles.

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
