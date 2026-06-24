---
name: plan-feature
description: Produce a detailed, research-validated implementation plan for any feature, refactor, or migration. Runs codebase exploration, drafts a plan, validates against current docs, and presents for approval. Output is a folder plans/in-flight/<slug>/ containing v1.md, v2.md, and research.md. On execution, the folder moves to plans/archive/<slug>/ and the entry in plans/ROADMAP.md flips from "In flight" to "Executed". Invoke at the start of any non-trivial work — 5+ files, new dependencies, or architectural changes.
---

# Plan Feature

This skill produces a research-validated plan for any feature. It runs in phases and outputs a **folder** in `plans/in-flight/<slug>/` containing `v1.md`, `v2.md`, and `research.md`. **No code is written during this skill.** On execution, the folder moves to `plans/archive/<slug>/` and the `plans/ROADMAP.md` entry flips from "In flight" to "Executed" — see [§ Archive on execute](#archive-on-execute) below.

## Philosophy

See `planning-philosophy` skill if available — that is the single source of truth and applies to both planning (this skill) and execution. The phases below are the structural enforcement of that philosophy.

## When to invoke

Invoke at the start of work that:
- Touches 5+ files
- Adds a new dependency
- Modifies schema, auth, or core architecture
- Spans multiple architectural layers
- Is a green-field feature

For trivial single-file changes, skip this skill and edit directly.

## Project Context Discovery

**Before starting, load project-specific context:**

1. **Read root `AGENTS.md`** (or `CLAUDE.md`) — contains project rules, conventions, and constraints
2. **Check for rules directory** — `.pi/rules/`, `.claude/rules/`, or similar for inviolable rules
3. **Read relevant skills** — look for `code-quality`, `planning-philosophy`, or similar in project's skills directory
4. **Identify tech stack** — from package.json, README, or AGENTS.md

This context becomes the foundation for Phase 0 constraints.

## Plan versioning

The skill produces **a folder of persistent plan files** per feature, all kept on disk under `plans/in-flight/<slug>/`:

- `plans/in-flight/<slug>/v1.md` — codebase-research-only draft from Phase 2. **Immutable after Phase 2 closes.** Historical record of what internal analysis produced.
- `plans/in-flight/<slug>/v2.md` — refined plan after Phase 3 external research and Phase 4 surgical edits. **The executable plan.** All execution proceeds from v2.
- `plans/in-flight/<slug>/research.md` — research findings, kept alongside v1 and v2 as a permanent audit artifact.

If anti-scope-creep produces substantial mid-execution changes, a `v3.md` is created. Small in-flight additions get appended as addenda to v2.

Why all three exist:
- Re-reading v1 + v2 + research reconstructs the full decision context if memory is stale
- The diff between v1 and v2 is a retrospective signal — heavily edited sections show where internal research wasn't sufficient
- Audit trail: every choice has a visible "before" and "after"

When the plan executes (Phase 7), the **whole folder** moves to `plans/archive/<slug>/` and a `README.md` is added summarizing outcome. The `plans/ROADMAP.md` entry flips from "In flight" to "Executed."

## Inputs to gather before starting

Ask the user (if not already provided):
- Feature description / problem statement
- Constraints (environment, alpha vs. prod, deadline)
- Scope cuts (what's explicitly OUT)
- Model/thinking preference (stronger models for crypto/CRDT/schema; lighter for mechanical work)
- Worktree vs. branch

---

## Phase 0 — Constraint extraction

Goal: extract and classify all invariants from the raw request **before** exploration begins.

Why first: constraints anchored after codebase exploration drift toward what's convenient, not what's required. Extract from the clean request while context is unbiased.

**Actions:**

1. Parse the feature description and user inputs for:
   - **Hard constraints** — non-negotiable (e.g. "must not break existing API", "no new tables", "must work on iOS Safari")
   - **Soft constraints** — preferences that can flex with reasoning (e.g. "prefer minimal changes", "ideally reuse the existing pattern")
   - **Scope boundaries** — explicit in-scope and out-of-scope declarations
   - **Rollback triggers** — conditions that mean stop and ask (e.g. "if it requires a schema migration, halt")
   - **Pre-existing constraints** from `AGENTS.md` and project rules that obviously apply to this feature area (quick skim — deep read happens in Phase 1)
2. If the request is vague, ask one focused question before continuing: "Are there hard constraints I should know before exploring the codebase?"
3. Produce the **ACTIVE CONSTRAINTS** block. This is copied verbatim into v1 and v2.

```
ACTIVE CONSTRAINTS
Hard:      [list or "none stated"]
Soft:      [list or "none stated"]
Scope in:  [list]
Scope out: [list]
Stop if:   [rollback triggers]
```

---

## Phase 1 — Codebase research

> **Active constraints:** Re-read hard constraints and scope boundaries before exploring. If exploration reveals the feature as stated violates a hard constraint, surface it now — not in Phase 5.

Goal: understand the existing terrain before designing anything.

**Actions:**
1. Spawn a subagent to map:
   - Files likely to be touched (from the feature description)
   - Existing patterns to reuse
   - Shared components in the affected area (modules used in 3+ places — these are blast-radius hazards)
   - Files in the affected area that exceed size/complexity budgets
2. Read every relevant `AGENTS.md`:
   - `/AGENTS.md` (root) — always
   - Any subdirectory `AGENTS.md` files in affected areas (these often contain critical constraints)
3. Skim project rules/skills for relevant standing rules

**Output of Phase 1:**

- List of reusable patterns (location + what to reuse for)
- List of files likely touched
- List of shared components requiring blast-radius care
- List of pre-existing constraints from AGENTS.md and rules

---

## Phase 2 — Draft plan v1

> **Active constraints:** Hard constraints and scope boundaries. Every substep in the implementation order must be checked against hard constraints before inclusion. Copy the ACTIVE CONSTRAINTS block verbatim into v1.

Goal: turn Phase 1 understanding into a concrete plan based on internal analysis only.

Save to `plans/in-flight/<slug>/v1.md` (create the folder first if needed). This file becomes **immutable** once Phase 2 closes — Phase 4 will copy it to v2 and edit v2 instead. Required sections:

```markdown
# <Feature Name>

## Active Constraints
(copy verbatim from Phase 0)

## Context
What problem this solves, why now, what is explicitly out of scope.

## Reusable Patterns
| Pattern | Location | Reuse for |

## File Map
### New files
| File | Purpose |
### Modified files
| File | Change |

## Implementation Order
Phased substeps. Each substep has:
- Short title
- Files touched
- Constraint check: which hard constraints are relevant to this substep
- "→ TEST" lines at every checkpoint
- Rollback: what to undo if this substep fails mid-execution

## Risk Tier per substep
LOW / MED / HIGH / CRITICAL — with one-line reason

## Stop-and-Ask Triggers
Specific halting points before: deps install, schema push, crypto code,
public API changes, anything replacing an existing pattern.

## Model / Thinking Recommendation
Per phase, with reason.
```

**Do not include code yet — descriptions only.**

---

## Phase 3 — Documentation + community research

> **Active constraints:** Soft constraints and scope boundaries. Research should resolve open questions from v1 — not relitigate settled hard constraints.

Goal: validate plan v1 against current external sources.

**For every new dependency** in the plan:
- WebSearch official docs (filter for current major version)
- Check breaking changes, peer-deps, maintenance status, last release date
- Confirm syntax for any non-trivial usage

**For every new pattern** (CRDT, custom provider, complex hook, novel encryption flow):
- Find at least 2 trusted community sources, post-2025
- Note known pitfalls and edge cases
- Cross-reference against any conflicting conventions in `AGENTS.md` or project rules

**Trusted source preference order:**
1. Official documentation of the library/framework
2. Official GitHub Discussions / Discord (linked from official site)
3. Maintainer's blog or conference talks (post-2025)
4. Stack Overflow answers post-2025 with accepted status and high score
5. Established tech publications post-2025

**Mandatory: 2026-current information.** If a source is older than 2024 or doesn't cite a library version, flag it and find an alternative. Library APIs move quickly; outdated sources actively mislead.

**Output of Phase 3:** A "Research Findings" document. Save as `plans/in-flight/<slug>/research.md` (kept alongside v1 and v2 as a permanent audit artifact). Each finding has:
- One-line summary
- Source link + date
- Verdict: confirms / conflicts / requires changes to plan v1

---

## Phase 4 — Produce plan v2 from v1

> **Active constraints:** All constraints — hard and soft. Each research-driven change to v1 must not violate a hard constraint. If a finding conflicts with a hard constraint, halt and ask — do not silently resolve it.

Goal: produce plan v2 by applying research findings to v1.

**Start by copying v1 to v2:**

```bash
cp plans/in-flight/<slug>/v1.md plans/in-flight/<slug>/v2.md
```

From this point, **edit only v2**. Never modify v1 — it is the historical record of the codebase-only analysis.

**Discipline for v2 edits:**
- Edit only sections that research findings impact
- Do not rewrite the plan wholesale
- Use `Edit` tool with specific `old_string` / `new_string` — diffs must be reviewable
- For each change, the Research Findings document must already explain why
- If a finding reveals a fundamental design flaw (e.g. the plan violates a key project rule), **halt and ask the user before redesigning that section**. Do not silently restructure.
- Add a brief `## Changelog from v1` section at the bottom of v2 listing each change and the finding ID that motivated it

---

## Phase 5 — Present for approval

> **Active constraints:** Hard constraints and rollback triggers. Present them explicitly so the user can verify the plan satisfies every one before approving execution.

Output to the user:
1. Paths to v2 (the executable plan), v1 (the historical draft), and the research findings document
2. Summary of what changed from v1 to v2 and why (cite specific findings)
3. List of open questions / decisions for the user
4. Risk highlights (CRITICAL substeps, anything novel, anything touching encryption)

**Wait for the user's confirmation, modifications, or scope adjustments before any code is written.** This is the hand-off from planning to execution.

If the user explicitly says "proceed" or "do not stop" during this skill, treat that as approval — note it in the plan as `Approved: [user directive]` and begin execution. Do not re-ask for permission already given.

---

## Anti-scope-creep mechanism (applies during execution too)

If during execution a new requirement or unknown surfaces:
1. Halt execution
2. Decide on the artifact:
   - **Small** finding → append an `## Addendum` section to v2 with date and description
   - **Substantial** finding (changes file map, risk tier, or architecture) → `cp v2.md v3.md` and edit v3
3. Notify the user with two options:
   - **Incorporate** into current plan (update scope, continue)
   - **Defer** to a follow-up plan (revert to original scope, log for later)
4. Do not proceed until the user picks one

This is the discipline that keeps long features from drifting.

---

## Phase 6 — Retrospective (post-ship, optional)

Invoke after the feature is merged and running. Inputs:
- v1, v2, v3 (if it exists), research findings document, plus any addenda

Run these comparisons:
- **Diff v1 vs v2** — sections most edited reveal where codebase-only research was insufficient. Refine Phase 1 exploration patterns for next time.
- **Diff v2 vs v3 / addenda** — surfaces what slipped past Phase 3 external research. Refine Phase 3 source list or research checklist.
- **What was learned** that should update `AGENTS.md` or project rules?
- **What patterns emerged** that should become reusable utilities or rules?
- **What stop-and-ask triggers** should be added to this skill based on near-misses?

**Output:** proposed updates to `AGENTS.md`, project rules, or this skill. User reviews and merges manually — don't auto-commit changes to project-wide guidance.

---

## Anti-patterns to avoid in this skill

- Skipping Phase 0 — constraints extracted after exploration drift toward what's convenient, not what's required
- Designing schema without reading project rules (hot-doc pattern violations are very expensive to fix later)
- Skipping research because "I know this library" — versions move; always confirm
- Writing any code before Phase 5 completes
- Rewriting plan v1 wholesale in Phase 4 — Phase 4 is surgical
- Implicit risk tiers ("this is fine") — every substep gets an explicit tier
- Treating Phase 3 as optional — it's the validation layer that catches design flaws before execution

---

## Cross-references

- **Execution discipline once a plan is approved:** `code-quality` skill (if available)
- **Project context:** `/AGENTS.md` or `/CLAUDE.md`
- **Project-specific rules:** Check `.pi/rules/`, `.claude/rules/`, or similar directories
- **Planning philosophy:** `planning-philosophy` skill (if available)

---

## Definition of done

The skill is complete when:
- `plans/in-flight/<slug>/v1.md` exists (immutable codebase-only draft)
- `plans/in-flight/<slug>/v2.md` exists, contains all required sections, and has a `## Changelog from v1` section
- `plans/in-flight/<slug>/research.md` exists and cites 2026-current sources for every novel choice
- A corresponding entry exists in `plans/ROADMAP.md` under **In flight**, linking to the v2 file
- All Stop-and-Ask Triggers in v2 are explicit
- User has approved, modified, or rejected v2
- No code has been written

Execution proceeds only from v2, only after explicit user approval.

## Archive on execute

When the user approves execution and the work is done (Phase 7), the executor must run **one command**:

```bash
./plans/archive.sh <date-slug>
```

This script does all four mechanical steps atomically:

1. **Move the plan folder** from `plans/in-flight/<slug>/` to `plans/archive/<slug>/`.
2. **Add a `README.md` to the archived folder** — copied from `plans/archive/_TEMPLATE-README.md`. The executor edits the `## Outcome` section to describe what shipped.
3. **Update `plans/ROADMAP.md`** — move the entry from **In flight** to **Executed**, update the link from `in-flight/<slug>/v2.md` to `archive/<slug>/v2.md`.
4. **Update `HANDOFF.md`** — append a one-line entry to **Recent decisions**.

The script is idempotent: re-running it on an already-archived plan is a noop. Run it in the same commit as the last execution step (or the commit immediately after, if the last step is a merge).

`oss-gate.yml` verifies the result with:
- Check 7: ROADMAP.md tracks in-flight plans
- Check 8: ROADMAP.md has the required sections
- Check 10: no orphan flat-folder plan files at `plans/` top level
