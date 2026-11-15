# Personal agent defaults

## Ongoing work

- For ongoing or open-ended work, set a goal before starting: one objective, the evidence that proves it done, the constraints that must hold, and the stop condition. Keep working across turns until the goal is met, the user stops or redirects it, or a blocker needs a decision; report meaningful findings and blockers as they appear.
- Codex, Claude Code, OpenCode 2.2.1+, and Muse Code all ship a native `/goal` command; use it rather than re-prompting yourself or hand-rolling a loop. `docs/agents.md` records how each one judges completion.
- Close a goal only on the evidence it names: a passing check, a command exit, a clean status, an artifact. Never on the model's own confidence that the work looks complete.
- If the host has no goal mechanism, record a clear checkpoint and state what is needed to continue; do not imply work will run unattended.

## Orchestration

- Default to one main loop with progressively disclosed skills and tools. Add delegation only after measuring a specific failure of that loop, and keep a subagent only for measurable context bloat, truly parallel work in a fresh context, or a conflict one loop cannot resolve. Fold other specialists into skills; `docs/agents.md` owns the routing.

## Long-running work

- Bridge context windows with committed artifacts and a checkpoint contract: objective, steps done, current step, next step. Prefer sessions with compaction over custom memory.

## Agent-Ready Project Standard

Set up every new personal repository or development project for effective agent work from the start:

- Create a concise root `AGENTS.md` that records the project purpose, architecture and ownership boundaries, canonical development and verification commands, toolchain conventions, generated-file rules, and important safety constraints.
- Add narrower `AGENTS.md` files only where a package or subtree genuinely needs different guidance. The nearest applicable file should refine, not duplicate, the root guidance.
- Keep durable project knowledge in version-controlled `README.md`, `docs/`, package documentation, or repo-local skills, and link to it from `AGENTS.md` rather than bloating the root file.
- Provide agent-discoverable setup such as an environment example, stable scripts for build/test/lint/format/typecheck, and explicit acceptance or verification expectations.
- Bring an existing repository to the same standard before substantive work: if the root `AGENTS.md` is missing, scaffold it from what the repo proves — verification command, bootstrap, boundaries, destructive operations. The in-repo artifact is `AGENTS.md`; do not add a repo-local `.agents/` collection, which duplicates skill discovery.

## Personal Project Development Defaults

For new personal development projects, use these defaults unless the user or project-local guidance specifies otherwise:

- Build full-stack applications on Cloudflare infrastructure and use Alchemy (`alchemy.run`) for infrastructure as code.
- Use TanStack Start and TanStack Router with shadcn/ui.
- Use Bun as the runtime and package manager, Vite for the build tool, and Oxlint/Oxfmt for linting and formatting.
- For Python, prefer the Astral toolchain, including `uv`, Ruff, and ty.

Treat this stack as a living preference rather than a frozen requirement. It may evolve as better tools emerge; follow the latest explicit guidance and do not migrate an established project unless asked.

## Personal Feature Development Skills

- Manage personal skills through the dotfiles repo: `skills-lock.json` owns pins and selections, `agents/personal-skills/` owns custom sources, and `scripts/install-skills.sh` deploys to the shared `~/.agents/skills` collection. Read `~/.agents/README.md` first; `docs/agents.md` owns the details. Inspect existing capabilities before adding overlapping skills.
- Inspect the available skills before substantial feature work. When a specialized workflow is missing, use `find-skills` and [skills.sh](https://skills.sh/) to discover relevant additions; recommend them before installing.
- Treat [emilkowalski/skills](https://github.com/emilkowalski/skills) as a preferred collection for design-engineering work, including UI quality, animation review, motion opportunities, prototyping, and UI-library selection.

## General engineering

- Do not preserve backward compatibility. Remove obsolete paths instead of adding compatibility layers, fallbacks, or migrations.
- Choose the simplest implementation that fully meets the current requirements. Avoid speculative abstractions, configuration, and indirection.
- Grow the system in layers. Start from the smallest version that works end to end, and add each new capability on top of a product that already works. Never trade a working product for unfinished complexity.
- Lean on the dependencies already in the project: check their docs and types before writing your own implementation or adding a package.
- Make architectural decisions for the long term. Do not accept a stopgap that only works for now and is meant to be replaced later.

## Project guidance

- Update guidance when a change makes it inaccurate, and keep documentation proportional to the task. Root guidance stays concise; procedures live in version-controlled docs or skills and are linked, not restated.
- Keep project-specific knowledge in its repository and cross-project preferences in global instructions. Exclude credentials, private transcripts, transient run status, and unconfirmed experiments.

## Context engineering

Guidance is context, and context is paid for on every turn: write only what the repo and the model cannot supply themselves.

- Spend the words on taste, gotchas, and definitions of done; delete what the filesystem, the types, or a sensible default already settles.
- Prefer structure to prose: a script, schema, enum, or test carries a constraint better than a paragraph.
- Delegate judgment where the default is fine; keep absolutes for irreversible or safety-relevant actions.
- State each rule once — repetition across files drifts into contradiction — and after a model upgrade, trim and re-verify against this repo's checks instead of trusting vendor evaluations.

## Governance

- Apply the Agent-Ready Project Standard to every repo before substantive work. Keep project-owned skills in the repo, never in repo-local `.agents/skills`.
- Improve guidance as you learn: when work exposes a missing convention, a gotcha, or a stale line, propose a minimal `AGENTS.md` diff in that session. Trigger on evidence — a failure the instructions would have prevented, a command that changed, a rule you had to infer — never on a schedule or general tidiness. One meaning per line; prune what the edit supersedes.
- Leave guidance changes uncommitted for human review unless the project's own instructions say otherwise; the human approves by committing.
