# Shared agent setup

Dotfiles owns the selection and versions of skills, plus your personal
instructions and customizations. Third-party packages are not vendored.

- Edit `agents/AGENTS.md` for shared personal instructions.
- Edit `agents/personal-skills/` for the three local/customized packages.
- Edit `.chezmoiexternal.toml` to add or update upstream skills. Each entry pins
  a full commit SHA, the selected archive path, and its SHA-256 checksum.

`chezmoi apply` downloads the 22 upstream skills into `~/.agents/skills`. It
verifies archive checksums and caches downloads. The same directory contains
links to personal skills in the dotfiles checkout. `~/.claude/skills` links to
this collection; Codex, Muse, and OpenCode discover it directly. Their native
personal-instruction entrypoints share `~/.agents/AGENTS.md`.

`chezmoi update` pulls the manifest and applies it. A skill changes only when
its pinned revision changes; repeating setup keeps the same versions.

Keep project-owned skills in their repositories. Credentials, MCP headers,
models, providers, sessions, plugins, and usage ledgers remain local.

## Update an upstream skill

Select and review an upstream commit. Update that skill's archive URL and
checksum in `.chezmoiexternal.toml`; keep the archive path correct. Then run:

```bash
bash scripts/test-chezmoi.sh
chezmoi diff
chezmoi apply
```

`exact = true` applies within an individual upstream skill directory, so files
removed upstream are also removed there. Put your changes in a personal variant
rather than editing downloaded packages.

Check discovery with `muse skills list --source user --json` or
`opencode debug skill`. External services/CLIs required by a skill are separate.

Sources: [chezmoi externals](https://www.chezmoi.io/reference/special-files/chezmoiexternal-format/),
[Codex](https://learn.chatgpt.com/docs/build-skills),
[Claude](https://code.claude.com/docs/en/skills),
[Muse](https://meta-models.github.io/muse-code-sdk/next/guides/extend/skills/),
[OpenCode](https://opencode.ai/docs/skills/).
