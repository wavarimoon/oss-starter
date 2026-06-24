# Contributing

Thanks for your interest in contributing. See `README.md` for the full picture.

By participating, you agree to the [`CODE_OF_CONDUCT.md`](./CODE_OF_CONDUCT.md).

## What this is

A self-maintaining open-source project with two layers:

- **AI layer** (`AGENTS.md`, `.pi/`, `.agents/skills/`) — convention + skill surface for AI coding agents working on this repo.
- **OSS layer** (`CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `.github/`) — GitHub-canonical contribution + community + security surface, with two CI workflows that auto-maintain the docs (`oss-gate.yml` and `doc-drift.yml`).

## First PRs

If you're new, these are good places to start:

- **Fix a broken link or typo** in `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, or `plans/`.
- **Improve a code comment or docstring** in any skill under `.agents/skills/`.
- **Add a missing example** to `CONTEXT.md` (domain glossary).
- **Improve an error message** anywhere — clearer messages save everyone time.
- **Translate** `CONTRIBUTING.md` or `README.md` into another language.

Look for issues labeled `good first issue` if/when they exist.

## Contribution surface

| Safe to touch | Avoid for now |
|---|---|
| Docs (`README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `plans/`) | Schema core, auth internals, deployment scripts |
| Skills (`.agents/skills/*/SKILL.md`) | Cloud infra / vendor configs |
| Examples and tests | Anything requiring a project-domain decision |
| Bug fixes with a linked issue | Anything explicitly marked `<!-- avoid: <reason> -->` |

When in doubt: open an issue first. The PR template will guide you.

## How to submit

1. Fork the repo (or create a branch if you have write access).
2. Make your change. Keep it small and focused — one PR per concern.
3. Fill in the [PR template](.github/PULL_REQUEST_TEMPLATE.md).
4. Open the PR. The `oss-gate` workflow will check the OSS file surface and the `doc-drift` workflow will run on merge to keep docs current.
5. Expect review feedback. We aim to respond within a week.

## How this project (and its OSS contract) evolves

This project follows the skeleton discipline. The architecture, the contribution surface, and even the OSS contract itself can change. Here is the meta-rule for contributors.

### Decision-making

- **Small** (typo fixes, single-file refactors, doc updates): just open a PR.
- **Medium** (new files, dependency changes, contribution-surface changes): open an issue, get a 👍 from a maintainer, then PR.
- **Large** (license changes, architectural pivots, opening up new surfaces): use `/skill:plan-feature` to produce a plan in `plans/`, then have a public discussion before merging.

### Changing the OSS contract itself

- **Adding to the "safe to touch" list** — open an issue first. The maintainer reviews whether it really is safe.
- **Removing from the "avoid" list** — only when the underlying code is stable. Update `CONTRIBUTING.md` in the same PR that stabilizes the code.
- **Filling in a "TBD" in any doc** — happens as part of the feature PR that adds the corresponding code. Not a standalone PR.
- **Adding new OSS contract files** — use `/skill:plan-feature` first. New files are only added if they earn a GitHub community-profile checkmark or run in CI.

## Code of conduct

All participants are expected to follow the [`CODE_OF_CONDUCT.md`](./CODE_OF_CONDUCT.md). Please report unacceptable behavior to the contacts listed there.

## Questions?

Open an issue with the `question` label.
