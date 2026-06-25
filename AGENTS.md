# AGENTS.md

Cross-harness AI agent constitution. Read by Pi, Claude Code, Cursor, opencode, Codex, Aider, Gemini CLI, Copilot.

> `CLAUDE.md` is a symlink to this file. On Windows without admin, replace the symlink with a one-line `CLAUDE.md` containing `@AGENTS.md`.

## What this is

A project constitution for AI agents working in this repository. The project's domain, language, and conventions live in `README.md`, `CONTEXT.md`, and `HANDOFF.md` — read those before assuming anything about the codebase.

## Quick commands

<!-- Fill in when the project adopts a toolchain.
Format: copy-pasteable commands for build, test, lint, run.

Example:
- Build: `npm run build`
- Test: `npm test`
- Lint: `npm run lint`
- Run: `npm start`
-->

## Inviolable rules

<!-- Fill in when the project's domain is known.
Examples:
- All changes must be backward-compatible within a major version
- No external network calls without explicit user consent
- Schema changes require a migration plan
-->

## Auto-loaded skills

| Skill | Purpose |
|-------|---------|
| `plan-feature` | Non-trivial features (5+ files, new deps, schema/auth/crypto). Produces v1/v2/research in `plans/`. |
| `planning-philosophy` | Earn the right to act before acting. |
| `tdd` | Red-Green-Refactor. |
| `code-quality` | Surgical edits, blast-radius, behavior-focused tests. |
| `gold-standard` | Project coding standard. Universal principles apply to every project. Stack-specific rules live in the marked section at the bottom and are filled in when the project adopts a toolchain. |
| `ponytail` | YAGNI pre-write check. The 7-rung ladder asks: does this need to exist? Is it already in the codebase? Does stdlib do it? Is there a one-line version? |

## Stop-and-ask triggers

Halt and ask the user before: new dependencies · schema/auth/crypto changes · replacing existing patterns · 5+ file edits · adding vendor directories. Run `/skill:plan-feature` for any of these.

## Open-source readiness

Before declaring work complete, see [`CONTRIBUTING.md`](./CONTRIBUTING.md) and ensure the `oss-gate` workflow (in `.github/workflows/oss-gate.yml`) is green. Before changing the contribution surface or any OSS-contract file, read [`CONTRIBUTING.md`](./CONTRIBUTING.md) § "How this project evolves."

## Plans workflow

For any non-trivial work (5+ files, new deps, schema/auth/crypto changes), drop a slug folder under [`plans/todo/`](./plans/todo/) to start a plan. Run `/skill:plan-feature` to produce a `plans/todo/<slug>/v2.md`, execute it, then run `./plans/archive.sh <slug>` to archive it to `plans/archive/<slug>.md` and remove the `todo/<slug>/` folder.

## Memory & continuity

- **Engram** is wired via `.pi/mcp.json`. The project slug is the `project` field there. If you fork oss-starter for a new project, provide `content/PI_PROJECT_NAME` when running the skeleton-setup skill and it will substitute the slug.
- Session start: read `HANDOFF.md` → read `CONTEXT.md` → query `mem_context`.
- Session end: update `HANDOFF.md` → `mem_session_summary`.
- After compact: save the summary, then `mem_context` before continuing.

---

_If you change this file, review `.agents/skills/` and `.pi/` in the same PR._