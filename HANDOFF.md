# Handoff

State ledger. Update when focus changes so the next session has clear context.
Older history lives in Engram via `mem_session_summary` — keep this file current, not archival.

## Current focus

_Fill in once the project has a first task. Each entry should be one paragraph: what is being worked on, why, and which plan (if any) drives it._

## Open work

_Bullet list of in-progress items. Link to issue or plan._

## Blocked

_Items that cannot proceed and why. Halt-and-ask triggers belong here until resolved._

## Recent decisions

_One bullet per decision, dated. Format: `- **Title** YYYY-MM-DD. Description. Link to plan.`_
- **Plan archived: 2026-06-23-setup-folder-refactor** — Consolidated setup assets INTO the skill folder (.agents/skills/skeleton-setup/). One rm -rf removes the entire kill folder. Q1 (refuse empty draft), Q2 (license confirmation), Q3 (pre-cleanup offer) baked into the agent flow. 9/9 oss-gate checks pass. Fixed: ROOT path resolution (2->3 ..), INPUT_GUIDE.md moved out of content/ (collision with apply-all).

## Merge discipline

- **OSS Gate:** PR cannot be merged until the `oss-gate` workflow is green.
- **Doc drift:** none currently — add a doc-drift detection workflow once the project adopts a toolchain.
- **Plan archive:** after a plan executes, run `./plans/archive.sh <slug>`. It writes a single `plans/archive/<slug>.md` (concatenated v1+v2+research+outcome), removes the in-flight folder, drops the entry from ROADMAP.md § In flight, and appends a one-line summary here.
- **Engram:** before ending a session, update this file and call `mem_session_summary`.
