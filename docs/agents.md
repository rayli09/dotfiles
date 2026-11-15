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

## Skill routing

Use these pointers to pick the narrowest skill for the branch in front of you.
Upstream descriptions are pinned; this table is the disambiguation layer.

- For Cloudflare CLI or deploy flows, load `wrangler`. For Workers code review or authoring, load `workers-best-practices`. For stateful coordination, load `durable-objects`. For sandboxed execution, load `sandbox-sdk`. For page performance, load `web-perf`. Reach for the `cloudflare` umbrella only when the task spans several of these or is platform-level triage.
- For building web animations, load `animate`. For React Native or Expo motion, load `animate-expo`. For auditing existing motion, load `review-animations` or `improve-animations`. For finding missing motion, load `find-animation-opportunities`. For vague motion wording, load `animation-vocabulary`. For frame drops, load `animation-performance`.
- For new visual direction, load `frontend-design`. For consolidated design-engineering philosophy, load `emil-design-eng`.
- `agents-sdk` in this catalog means Cloudflare Workers agents. For OpenAI Agents SDK or other providers, search upstream instead of loading this skill.
- Manual-only skills (`pick-ui-library`, `prototype`) run only on explicit invocation, they do not auto-trigger.

## Orchestration

Reference behind the pointer in `agents/AGENTS.md`. Load only when delegation is under consideration.

- Orchestrate repeatable work via code, open-ended work via LLM routing.
- Use `handoff` when the specialist should answer the user, `agent-as-tool` when the manager should synthesize the final answer.
- Use `subagents` for single-session delegation that returns a result, `agent teams` for multi-session coordination with a shared task list.

## Long-running

Reference behind the pointer in `agents/AGENTS.md`. Load only when work spans sessions or resumes from a checkpoint.

- Seed once per project: `init.sh` (boot the dev server, run a baseline check), `feature_list.json` (one entry per end-to-end behavior, all failing), a progress log (`claude-progress.txt` or `PROGRESS.md`, empty), then an initial git commit.
- Feature entry shape: id, category, description as observable behavior, steps, status. Flip status to passing only after end-to-end verification as a human user would.
- Start each session by reading the progress log, the feature list, and recent `git log`, then running `init.sh` and verifying baseline health before new work. Implement one feature at a time; end with a descriptive commit plus a progress entry. Keep the tree mergeable: no half-implemented undocumented features.
- Git-track the handoff (spec, feature list, progress log, `init.sh`, code, tests). Keep transcripts, raw logs, scratch output, secrets, and generated runtime out of git.
- Checkpoint contract: objective, steps done, current step, next step.
- For builds where quality keeps drifting, add an evaluator with gradable criteria alongside planner and generator.

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
