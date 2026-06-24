# Plans

This directory holds feature plans produced by the [`plan-feature`](../.agents/skills/plan-feature/SKILL.md) workflow, plus the [ROADMAP.md](./ROADMAP.md) to-do list.

A fresh project starts with `plans/` containing only this file and `ROADMAP.md`. The `in-flight/` and `archive/` subfolders appear as work happens.

## Layout

```
plans/
├── README.md        ← you are here (workflow + layout)
├── ROADMAP.md       ← the to-do list (Backlog / In flight)
├── archive.sh       ← one-command archive ritual
├── in-flight/       ← plans currently being written or executed (created on first plan)
│   └── <slug>/
│       ├── v1.md
│       ├── v2.md
│       └── research.md
└── archive/         ← executed plans, one .md file per plan
    └── <slug>.md    ← concatenated v1 + v2 + research + outcome
```

## Workflow (one-liner)

**Plan → in-flight → execute → archive.sh → done.**

```bash
# 1. Start a plan (assumes the slug is already in ROADMAP.md § Backlog)
/skill:plan-feature my-feature       # → produces in-flight/my-feature/{v1,v2,research}.md

# 2. Execute the plan (write code, open PRs, merge)

# 3. Archive it (one command does everything atomically)
./plans/archive.sh my-feature "One-line outcome description."

# 4. Push and let oss-gate verify
git push
```

The `oss-gate` workflow (checks 7–9) verifies the result is consistent on every PR.

## Plan versioning

Each plan folder under `in-flight/` contains three files:

- `<slug>-v1.md` — codebase-research-only draft. **Immutable** historical record.
- `<slug>-v2.md` — refined executable plan after research. **The plan we execute from.**
- `<slug>-research.md` — research findings (per-dependency, per-pattern, with 2026-current sources).

When `archive.sh` runs, these three are concatenated into a single `archive/<slug>.md` with an `**Outcome:**` header.

Why both v1 and v2 exist:
- Re-reading v1 + v2 reconstructs the full decision context if memory is stale.
- The diff between v1 and v2 is a retrospective signal — heavily edited sections show where internal research wasn't sufficient.
- Audit trail: every choice has a visible "before" and "after."

## Index

- [`ROADMAP.md`](./ROADMAP.md) — the live to-do list (Backlog, In flight)
- [`archive.sh`](./archive.sh) — the archive ritual