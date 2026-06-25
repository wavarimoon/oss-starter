# Plans

This directory holds implementation plans. Every non-trivial feature, refactor, or migration gets a plan before code is written.

## Directory layout

```
plans/
├── README.md        ← you are here
├── archive.sh       ← run to archive a completed plan
├── todo/            ← active plans (one folder per plan)
│   └── <slug>/
│       ├── v1.md    ← initial approach (may be superseded)
│       ├── v2.md    ← revised approach (required)
│       └── research.md  ← investigation notes, spikes, references
└── archive/
    └── <slug>.md    ← concatenated v1 + v2 + research + outcome
```

## How it works

```
Plan → todo/<slug>/ → execute → archive.sh → archive/<slug>.md → done
```

1. **Start a plan** — create `plans/todo/<slug>/` with at least a `v2.md`.
2. **Execute** — work through the plan. Update `v2.md` as the approach evolves. Spawn `v1.md` if the first attempt was superseded.
3. **Archive** — run `./plans/archive.sh <slug> [outcome]`. This concatenates the plan files into `plans/archive/<slug>.md`, removes the `todo/<slug>/` folder, and appends a line to `HANDOFF.md § Recent decisions`.

A plan exists when its folder exists under `todo/`. It is done when `archive.sh` moves it to `archive/`. There is no separate backlog list or in-flight list — `todo/` is the only queue.

## Versioning rationale

Plans carry three versioned documents:

- **v1.md** — the initial approach. Kept for the audit trail even if v2 superseded it completely.
- **v2.md** — the revised or final approach. This is the primary document.
- **research.md** — investigation notes, spikes, benchmark results, or reference material that informed the plan.

Keeping both v1 and v2 lets future agents (and humans) understand *why* the plan changed, not just what it became. This is especially valuable for cross-harness work where different agents may pick up at different points.

## Commands

```bash
# Start a plan
mkdir -p plans/todo/my-feature
$EDITOR plans/todo/my-feature/v2.md

# Archive a completed plan
./plans/archive.sh my-feature "Decided to use approach X over Y"

# Dry run (see what would happen)
./plans/archive.sh --dry-run my-feature
```

## Index

<!-- Update when plans are added or archived -->

| Plan | Status | Date |
|------|--------|------|
| _(none yet)_ | — | — |
