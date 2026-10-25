# Shared skills and agent guidance

From the dotfiles checkout:

```bash
bash scripts/install-tools.sh
bash scripts/install-skills.sh
bash scripts/check-skills.sh
```

`chezmoi update` also restores skills when the catalog or installer changes,
before applying agent links. The normal full installer prepares system packages
first. No third-party skill files are committed to this repository.

## Ownership

- `skills-lock.json` is the Skills CLI-generated catalog: upstream commit pins,
  exact skill paths, content hashes, and relative custom sources.
- `agents/personal-skills/` owns custom skills and customized upstream variants.
- `agents/runtime/` is the generated, ignored collection. The pinned Skills CLI
  in mise owns its contents; chezmoi only links `~/.agents/skills` to it.
- Claude links to that same collection. Codex, Muse, and OpenCode discover the
  shared collection directly. Keeping generated skills outside repository
  `.agents/skills` avoids a second project-scope discovery path. `agents/AGENTS.md` owns shared instructions.

Project-owned skills stay in their projects. Managed system skills and plugins,
credentials, providers, sessions, and MCP settings remain in their own locations.

## Discover and review changes

Activate the shared tools, then use `skills find`, `skills add <repo> --list`,
and `skills list --global`. Make catalog changes in a review checkout so CLI mutations do
not change your live collection before review.

For example, this selects one skill at a full reviewed commit:

```bash
source scripts/tools-env.sh
skills add 'emilkowalski/skills#2d228630ba1446365f614a108cb8252f1feda202' \
  --skill animate --agent codex --yes
git diff -- skills-lock.json
bash scripts/install-skills.sh
bash scripts/test-skills.sh
```

To refresh a custom skill after editing its source:

```bash
skills add ./agents/personal-skills/college-ps --agent codex --yes
```

Commit the catalog and custom source changes together. The verified installer
accepts full Git commit SHAs, not floating branches/tags, and reserves custom
skill names for their local sources. New sources or CLI upgrades require tests.

## Frozen restoration

The installer runs the pinned CLI's `experimental_install` in a staging
checkout with the custom sources. It rejects changed catalog bytes, wrong
inventories, changed custom sources, and mismatched content hashes before
replacing the prior generated collection. A failed restore preserves the
previous collection. Verification may also target another discovery path:

```bash
bash scripts/check-skills.sh "$HOME/.agents/skills"
```

Skills CLI 1.7.4 can rewrite lock hashes during restoration, so its lockfile is
not a frozen-install guarantee by itself. `skills check` also uses its updater
and can mutate installations; run check/update commands in a review checkout.
Our verified installer supplies the missing fail-closed boundary.

## Tests and discovery

`bash scripts/test-skills.sh` uses a separate source copy. It tests cold/repeat
CLI restoration, unchanged metadata, custom files, agent links, and rejection of
corrupt content, rewritten hashes, floating refs, and custom-name collisions.
Full Ubuntu/Debian installation tests exercise the chezmoi hook as well.
Restart coding agents after changing skills. Where available, inspect discovery
with `muse skills list --source user --json` and `opencode debug skill`.

References: [Skills CLI](https://github.com/vercel-labs/skills/blob/main/docs/commands.md)
· [Agent Skills format](https://agentskills.io/specification)
