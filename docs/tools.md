# Portable tools

From a dotfiles checkout, install the shared toolchain and activate it:

```bash
bash scripts/install-tools.sh
source "$HOME/.local/share/dotfiles-tools/env.sh"
```

The same installer is used by personal-machine setup and dev-workbench. It
installs Node/npm, Bun, pnpm, Go, Python/uv, TypeScript, Oxlint/Oxfmt, Ruff, and ty.
Versions and Node/Go archive checksums live in `toolchain.env`.

## Sandboxes and agents

The installer needs Bash, curl, Git, tar, awk, and a SHA-256 utility. Linux also
needs the runtime's system libraries (on Ubuntu/Debian, `libatomic1` and
`libstdc++6`). Linux and macOS on x64 and arm64 are supported.

Installation needs no sudo and makes no shell, Git, editor, or agent-config
changes. Source the installed `env.sh` in each new command shell. For a custom
location, export `DOTFILES_TOOLS_PREFIX` before installation and activation:

```bash
export DOTFILES_TOOLS_PREFIX="$PWD/.tools"
bash scripts/install-tools.sh
source "$DOTFILES_TOOLS_PREFIX/env.sh"
```

Use the application's runtime requirements and lockfile for project commands.
Shared defaults provide a starting environment; they do not override a project's
versions. Personal configuration is an explicit choice through the full
`install.sh` entrypoint, documented in [setup](setup.md).

## Updating

Resolve and review versions from official vendor releases and npm/PyPI. Update
`toolchain.env`, including Node/Go archive checksums, then run the install and
checks. Installation reapplies those pins; it does not resolve floating latest
versions. `scripts/check-tools.sh` verifies exact versions and executes small
JavaScript, TypeScript, Python, and Go checks.

Dev-workbench pins a dotfiles commit through its `dotfiles` Git submodule and
adds Cloud-specific tools. Update and test that pin deliberately; changes to
this repository's main branch do not change an existing workbench pin.

## Tests

```bash
docker build -f Containerfile.tools -t dotfiles-tools .
docker run --rm dotfiles-tools
```

This tests fresh/repeat installation without sudo, activation in a new Bash
shell, exact versions, executable checks, and preservation of personal config.
CI also runs the tools test on native macOS. Full personal-machine installation
is tested separately; see [setup](setup.md#container-tests).
