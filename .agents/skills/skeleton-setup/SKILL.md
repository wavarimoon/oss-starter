---
name: skeleton-setup
description: One-shot self-cleaning setup of a new project from this skeleton. The agent reads whatever the user dropped into content/, asks 1-3 clarifying questions, pauses for a license decision, offers to keep/relocate draft assets before cleanup, then invokes mechanical subcommands and removes the entire skill folder. Use exactly once per project.
---

# skeleton-setup

The kill folder is the skill folder itself: `.agents/skills/skeleton-setup/`. **Everything consumed by this skill lives inside it** (content, licenses, the mechanical script). When the skill finishes, the entire folder is removed with one `rm -rf`. The skill cannot be re-run on a generated project — re-clone the skeleton if needed.

## When to invoke

Invoke when the user has populated `content/` and wants the project materialized. Triggers:

- "Set up the project from this skeleton."
- "Materialize the project."
- "Run skeleton-setup."

## When NOT to invoke

- **`content/` is empty.** See Q1 below — refuse and ask the user to drop something first.
- On a generated project. The skill is gone by then.
- Twice on the same skeleton. The idempotency guard will refuse the second run with exit 2.

## What to read first

Before doing anything:

1. `AGENTS.md` — the project-level agent constitution.
2. This file (SKILL.md) — the agent contract.
3. `INPUT_GUIDE.md` — the input contract (what files mean in `content/`).
4. `licenses/README.md` — SPDX id reference for license choice.

## The flow (8 phases)

The agent drives this. The mechanical script (sibling `skeleton-setup.sh`) is invoked at phases 5 and 7. Judgment is the agent's; the script is dumb on purpose.

### Phase 1 — Discovery
Confirm the user wants to materialize the project. Read this file, `INPUT_GUIDE.md`, `licenses/README.md`.

### Phase 2 — Inference
Read whatever is in `content/`. Form a picture: project name, domain, target audience, license hints, maintainers, anything else.

### Phase 3 — Clarification (judgment)
Ask 1–3 targeted questions for anything ambiguous. **This is where Q1 lives.**

### Phase 4 — License decision (judgment)
**Q2.** If `content/LICENSE` is absent, the agent pauses:
1. Recommend ONE license based on the inferred project shape. Reasoning must cite the project signals that drove the choice.
2. List 1–2 alternatives with their tradeoffs.
3. Ask the user to confirm one of: the recommendation, an alternative, or a different license they specify.
4. After confirmation, write `content/LICENSE` with the chosen SPDX id (lowercase, e.g. `mit`).

If `content/LICENSE` is already present, skip the pause and use that id.

GitHub population happens when the user pushes after Phase 8 — no script action needed; the LICENSE file lands at repo root.

### Phase 5 — Mechanical execution
Invoke subcommands from `skeleton-setup.sh` in order, or use `apply-all` to discover and dispatch:

```sh
# Single-shot (recommended for full content/):
./.agents/skills/skeleton-setup/skeleton-setup.sh --dry-run apply-all   # preview
./.agents/skills/skeleton-setup/skeleton-setup.sh apply-all             # execute
```

Or call individual subcommands if the agent wants finer control:

```sh
./.agents/skills/skeleton-setup/skeleton-setup.sh apply-license apache-2.0
./.agents/skills/skeleton-setup/skeleton-setup.sh generate-codeowners
./.agents/skills/skeleton-setup/skeleton-setup.sh substitute-pi-name my-slug
./.agents/skills/skeleton-setup/skeleton-setup.sh apply-readme
./.agents/skills/skeleton-setup/skeleton-setup.sh apply-agents
./.agents/skills/skeleton-setup/skeleton-setup.sh apply-context
./.agents/skills/skeleton-setup/skeleton-setup.sh apply-handoff
```

`apply-all` stops before `self-cleanup` so the agent can run Phase 6.

### Phase 6 — Pre-cleanup offer (judgment)
**Q3.** Before invoking `self-cleanup`, the agent must:

1. **Warn** that this is one-shot. The entire `.agents/skills/skeleton-setup/` folder (including any unprocessed draft assets in `content/`) will be deleted.
2. **List** what's in the skill folder that will be removed (run `ls -la` and report).
3. **Offer the user options:**
   - "Delete everything" — proceed to self-cleanup.
   - "Keep these N files" — list paths; agent moves them to a project location before self-cleanup.
   - "Move these M files to <path>" — agent relocates them, then self-cleanup.
   - "Stop" — abort; the skill folder is preserved and the user can iterate.

   Common case for "keep/move": the user dropped images or reference docs into `content/` that they want to retain in the project (e.g. `content/logo.png` → `assets/logo.png`).

4. Wait for the user's response. Only then proceed.

### Phase 7 — Self-cleanup
After Q3 resolution:

```sh
./.agents/skills/skeleton-setup/skeleton-setup.sh self-cleanup
```

This is `rm -rf .agents/skills/skeleton-setup/`. After this, the script itself is gone — re-invoking will fail (which is correct: the skill is one-shot).

### Phase 8 — Report
Print a summary: what was written, what was kept/relocated, what's next:

```
Next steps:
  1. Edit README.md, CONTRIBUTING.md, and any files still marked TODO.
  2. git init && git add . && git commit -m 'Initial commit from skeleton'
  3. Push to your remote.
  4. Verify the project's oss-gate passes (or write your own first).
```

## How to talk to the user at Q1/Q2/Q3

**Be terse.** Two to four lines max per response. The user knows what they're doing. Don't explain the contract — just ask the question and stop.

Bad: long bullet list of acceptable inputs, full paragraph explaining why defaults don't work, repeating back what the contract says.

Good: one or two sentences, then the question.

## Q1: Empty-draft handling

If `content/` is empty or doesn't exist, refuse to run. Tell the user to drop something (a README draft, a project idea, a LICENSE choice, an image — anything). One line, then stop.

> Example: "`content/` is empty. Drop a README draft, a project idea, or any file in there and ask me to run skeleton-setup again."

## Q2: License decision

If `content/LICENSE` is absent, pick a recommendation from the rubric below. Tell the user: the recommended SPDX id (one-line reason), one alternative (one-line tradeoff), then ask them to confirm or pick something else. Wait for explicit answer. Then write `content/LICENSE` with the chosen id.

> Example: "I recommend `apache-2.0` (default, patent grant). Alternative: `mit` (simpler, no patent grant). Which? You can also name a different one."

| Signal in `content/` | Recommend |
|---|---|
| Library / tool for others | `mit` |
| Enterprise / corporate / patent-sensitive | `apache-2.0` |
| C/C++/system tool | `bsd-3-clause` |
| User mentions "copyleft" or "MPL" | match their signal |
| Network service you want to keep free | `agpl-3.0` |
| No signal | `apache-2.0` |

## Q3: Pre-cleanup offer

Before `self-cleanup`, list the files about to be deleted (one `ls -la`) and ask: delete everything, keep specific files, move specific files, or abort. Wait for answer.

> Example: "About to delete `.agents/skills/skeleton-setup/` (the SKILL.md, script, licenses/, and any draft in content/). Delete everything, keep specific files, move specific files, or abort?"

## Mechanical subcommands reference

| Subcommand | Purpose |
|---|---|
| `apply-license <spdx-id>` | Copy `licenses/<file>` → root `LICENSE` |
| `generate-codeowners` | Read `content/MAINTAINERS.md` → write `.github/CODEOWNERS` |
| `substitute-pi-name <slug>` | Replace `<project-slug>` in `.pi/mcp.json` + `.pi/settings.json` |
| `apply-readme` / `-agents` / `-context` / `-handoff` | Copy `content/<file>` → root `<file>` |
| `apply-all` | Discover and dispatch. Stops before `self-cleanup`. |
| `self-cleanup` | `rm -rf .agents/skills/skeleton-setup/`. The script is consumed by this. |
| `--help` | Print usage |

Global `--dry-run` flag (before subcommand) prints the plan without making changes.

## What the agent should NOT do

- **Do not auto-confirm the license.** Q2 requires the user to choose. The script trusts whatever SPDX id is passed; the agent's job is to make the user pick.
- **Do not skip Q3.** The user gets the pre-cleanup offer every time. There is no "fast path" that bypasses it.
- **Do not run with empty `content/`.** Q1 refusal is mandatory.
- **Do not modify `skeleton-setup.sh` from this skill's invocation.** The script is the contract. If it needs to change, that is a planning task.
- **Do not re-invoke after a successful run.** The guard will trip with exit 2.

## What this skill does NOT do (explicit non-goals)

- It does not `git init` the project. The user runs that themselves.
- It does not push to any remote.
- It does not install language-specific tooling. The skeleton is domain-agnostic.
- It does not choose the project's license on the user's behalf (Q2 is mandatory).
- It does not silently drop into defaults when `content/` is empty (Q1 is mandatory).

## Anti-patterns to avoid

- **Running the script directly without the agent flow.** The script is mechanical. Q1, Q2, Q3 are agent responsibilities. Running the script alone skips all three.
- **Modifying the script to "add prompts" to the script body.** Prompts belong in the agent's flow, not in the shell. The script must remain CI-friendly (batch-runnable, no interactivity).
- **Bypassing Q2 with a "good default".** Even if Apache-2.0 is the skeleton's default, the user gets the choice when their input didn't pin a license.
- **Bypassing Q3 with "the user said yes, just clean up".** Re-confirm if there's any draft content beyond the consumed files.
