# Personal agent defaults

## Ongoing work

- For ongoing or open-ended work, set a goal before starting: one objective, the evidence that proves it done, the constraints that must hold, and the stop condition. Keep working across turns until the goal is met, the user stops or redirects it, or a blocker needs a decision; report meaningful findings and blockers as they appear.
- Codex, Claude Code, OpenCode 2.2.1+, and Muse Code all ship a native `/goal` command. Use it rather than re-prompting yourself or hand-rolling a loop, and check that the command exists before relying on it.
- Close a goal only on the evidence it names: a passing check, a command exit, a clean status, an artifact. Never on the model's own confidence that the work looks complete.
- If the host has no goal mechanism, record a clear checkpoint and state what is needed to continue; do not imply work will run unattended.

## Orchestration

- Default to one main loop with progressively disclosed Skills and tools. Add delegation only after measuring a specific failure of the single loop.
- Keep a subagent only for measurable context bloat, true parallel work in fresh contexts, or a tool or instruction conflict a single loop cannot resolve. Fold other specialists into Skills and tools; choose routing per branch in `docs/agents.md`.

## Long-running work

- Bridge context windows with committed artifacts (task list, notes, handoff state). Each session leaves a reusable checkpoint.
- Prefer sessions with compaction over custom memory. Checkpoint contract: objective, steps done, current step, next step.

## Agent-Ready Project Standard

Set up every new personal repository or development project for effective agent work from the start:

- Create a concise root `AGENTS.md` that records the project purpose, architecture and ownership boundaries, canonical development and verification commands, toolchain conventions, generated-file rules, and important safety constraints.
- Add narrower `AGENTS.md` files only where a package or subtree genuinely needs different guidance. The nearest applicable file should refine, not duplicate, the root guidance.
- Keep durable project knowledge in version-controlled `README.md`, `docs/`, package documentation, or repo-local skills, and link to it from `AGENTS.md` rather than bloating the root file.
- Provide agent-discoverable setup such as an environment example, stable scripts for build/test/lint/format/typecheck, and explicit acceptance or verification expectations.

## Personal Project Development Defaults

For new personal development projects, use these defaults unless the user or project-local guidance specifies otherwise:

- Build full-stack applications on Cloudflare infrastructure and use Alchemy (`alchemy.run`) for infrastructure as code.
- Use TanStack Start and TanStack Router with shadcn/ui.
- Use Bun as the runtime and package manager, Vite for the build tool, and Oxlint/Oxfmt for linting and formatting.
- For Python, prefer the Astral toolchain, including `uv`, Ruff, and ty.

Treat this stack as a living preference rather than a frozen requirement. It may evolve as better tools emerge; follow the latest explicit guidance and do not migrate an established project unless asked.

## Personal Feature Development Skills

- Manage personal skills through the dotfiles repo: `skills-lock.json` owns upstream commit pins and custom selections; keep custom sources in `agents/personal-skills/`. Use the pinned Skills CLI for authoring and `scripts/install-skills.sh` for verified deployment to the shared `~/.agents/skills` collection. Read `~/.agents/README.md` before changing selections. Keep project-owned skills in their repositories and managed system skills/plugins in their managed locations; inspect existing capabilities before adding overlapping skills.
- Inspect the available skills before substantial feature work. When a specialized workflow is missing, use `find-skills` and [skills.sh](https://skills.sh/) to discover relevant additions; recommend them before installing.
- Treat [emilkowalski/skills](https://github.com/emilkowalski/skills) as a preferred collection for design-engineering work, including UI quality, animation review, motion opportunities, prototyping, and UI-library selection.

## General engineering

- Do not preserve backward compatibility. Remove obsolete paths instead of adding compatibility layers, fallbacks, or migrations.
- Choose the simplest implementation that fully meets the current requirements. Avoid speculative abstractions, configuration, and indirection.
- Grow the system in layers. Start from the smallest version that works end to end, and add each new capability on top of a product that already works. Never trade a working product for unfinished complexity.
- Keep components modular and concerns clearly separated.
- Prefer established, well-maintained libraries when they reduce overall complexity or improve reliability. Do not reimplement common functionality without a clear reason.
- Lean on the dependencies already in the project before writing your own implementation or adding packages. Do not assume a library lacks a capability without checking its documentation and types.
- Make architectural decisions for the long term. Do not accept a stopgap that only works for now and is meant to be replaced later.

## Project guidance

- Update project guidance when requested or when a change makes existing instructions inaccurate. Keep documentation work proportional to the task.
- Keep root guidance concise; put detailed procedures in version-controlled docs or repo-local skills.
- Keep project-specific knowledge in its repository and cross-project preferences in global instructions. Exclude credentials, private transcripts, transient run status, and unconfirmed experiments.

## Governance

- Scaffold every new repo per the Agent-Ready Project Standard before substantive work: root `AGENTS.md`, durable knowledge in `README`/`docs`, env example, stable verification scripts. Use the shared skills collection; keep project-owned skills in the repo, never in repo-local `.agents/skills`.
- Improve guidance as you learn: after substantive work, propose an `AGENTS.md` amendment as a diff when a convention, gotcha, or stale line surfaced. One meaning per line; prune what the edit supersedes.
- Leave guidance changes uncommitted for human review. The human approves by committing.
