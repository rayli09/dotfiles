# Portable tools

From a dotfiles checkout:

```bash
bash scripts/install-tools.sh
source "$HOME/.local/share/dotfiles-tools/env.sh"
```

Personal-machine setup and dev-workbench use this same entrypoint. Chezmoi
manages personal files; mise owns the shared tools.

## Sandboxes and agents

Installation supports Linux/macOS on x64/arm64 and needs Bash, curl, Git, tar,
awk, and a SHA-256 utility. Linux needs runtime libraries (`libatomic1` and
`libstdc++6` on Ubuntu/Debian). No sudo or shell-profile edits are required.

Source the installed `env.sh` in each command shell. It puts mise and its shims
on PATH, with configuration, tools, and caches isolated under the install prefix.
Project mise configuration can override the shared defaults. Review and trust
an application's mise configuration before running its tools.

For a custom location:

```bash
export DOTFILES_TOOLS_PREFIX="$PWD/.tools"
bash scripts/install-tools.sh
source "$DOTFILES_TOOLS_PREFIX/env.sh"
```

The installer deploys the reviewed manifest as that prefix's global defaults
and runs `mise install --locked`. Personal shell, Git, editor, and agent setup
remains an explicit choice through the full [installer](setup.md).

## Versions and updates

`mise.toml` declares Node/npm, Bun, pnpm, Go, Python/uv, TypeScript, Oxlint/Oxfmt,
Ruff, and ty. `mise.lock` pins artifacts for all four supported platforms.
Commit `.mise/locks/` too: it holds locked npm dependency graphs.

After reviewing a version change in `mise.toml`:

```bash
source "$HOME/.local/share/dotfiles-tools/env.sh"
mise trust mise.toml
mise lock
bash scripts/install-tools.sh
```

Generate lockfiles with the pinned mise release; do not hand-edit lockfiles or
sidecars. Installation must leave them unchanged. `mise-bootstrap.env` pins only
mise itself and the four official binary checksums; update it alongside
`min_version` when upgrading mise.

Dev-workbench pins a tested dotfiles commit and adds Cloud/native/media tools.
Changing main does not change that pin. Application runtime requirements and
lockfiles remain with the application.

## Tests

```bash
docker build -f Containerfile.tools -t dotfiles-tools .
docker run --rm dotfiles-tools
```

Tests cover unprivileged fresh/repeat installs, exact executable versions,
JavaScript/TypeScript/Python/Go execution, fresh-shell activation, personal-config
preservation, unchanged locks, project overrides, and rejection of unpinned
requests. CI also tests native macOS. Full personal-machine setup is tested
separately; see [setup](setup.md#container-tests).
