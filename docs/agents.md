# Shared agent setup

This repository is the source of truth. Edit `agents/AGENTS.md` for personal
project defaults and general engineering guidance, and
`agents/skills/<name>/` for reusable skills. The 25 skill packages are
vendored, with available upstream source metadata in `agents/sources.json`.

chezmoi links `~/.agents/skills` and `~/.agents/AGENTS.md` directly into its
checkout, so there are no independently maintained copies. Claude's personal
skill directory links to the same collection. Codex, Muse, and OpenCode discover
the shared collection directly. Native personal-instruction entrypoints for
Codex, Claude, and OpenCode link to the shared defaults; Muse can import the
Claude/Codex personal rules through its built-in compatibility support.

Repository-owned skills stay in repositories. Credentials, MCP headers, model
choices, provider settings, sessions, plugins, and usage ledgers are local.
This repo does not sync complete agent configuration files.

A skill's directory must match its frontmatter `name`, and its `description`
should be short and specific. Tool-specific scripts may need their own CLI
dependencies; installing a skill does not provision its external services.

Check discovery with `muse skills list --source user --json` or
`opencode debug skill`. Validate a package with `muse skills validate <path>`.

Sources: [Codex](https://learn.chatgpt.com/docs/build-skills),
[Claude](https://code.claude.com/docs/en/skills),
[Muse](https://meta-models.github.io/muse-code-sdk/next/guides/extend/skills/),
[OpenCode](https://opencode.ai/docs/skills/).
