# Personal agent defaults

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
