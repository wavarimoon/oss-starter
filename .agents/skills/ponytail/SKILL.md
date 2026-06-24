---
name: ponytail
description: >
  Force the laziest solution that actually works. Before writing code, the
  agent stops at the first rung that holds. Channels a senior dev who has
  seen everything: question whether the task needs to exist at all (YAGNI),
  reach for the standard library before custom code, native platform features
  before dependencies, one line before fifty. Use whenever the user says
  "ponytail", "be lazy", "lazy mode", "simplest solution", "minimal
  solution", "yagni", "do less", "shortest path", and whenever they
  complain about over-engineering, bloat, boilerplate, or unnecessary
  dependencies.
license: MIT (adapted from DietrichGebert/ponytail)
---

# Ponytail

The YAGNI pre-write check. Other skills in this repo (`gold-standard`,
`code-quality`, `tdd`) are *post-write* disciplines. Ponytail runs *before*
writing — at the moment of deciding whether to write at all.

## The ladder

Before writing code, stop at the first rung that holds:

1. **Does this need to exist?** → no: skip it (YAGNI)
2. **Already in this codebase?** → reuse it, don't rewrite
3. **Stdlib does it?** → use it
4. **Native platform feature?** → use it
5. **Installed dependency?** → use it
6. **One line?** → one line
7. **Only then:** the minimum that works

The ladder runs *after* understanding the problem, not instead of it: read
the code the change touches and trace the real flow before picking a rung.
Lazy about the solution, never about reading.

## Boundaries — lazy, not negligent

Never on the chopping block:

- Trust-boundary validation
- Data-loss handling
- Security
- Accessibility
- Errors are values (per `gold-standard`)

If the minimum that works omits one of these, it isn't minimum — it's broken.

## Intensity levels

- **lite** — gentle YAGNI reminders. Default for routine work.
- **full** — strict ladder. Default when the user invokes `/ponytail`.
- **ultra** — every line must justify its existence. For cleanup passes.

State lives in `HANDOFF.md` § Recent decisions if a session changes level.

## Anti-patterns this skill catches

- Adding a helper for one call site (rung 2 says wait for three).
- Reaching for a library when stdlib does it (rung 3).
- Writing a custom abstraction when the platform already has one (rung 4).
- A 50-line function when a 1-line stdlib call exists (rung 6).
- "I'll need this later" code (rung 1 fails).

## Composes with

- `planning-philosophy` — both enforce "earn the right to act."
- `gold-standard` § Universal principles — same ladder, different rungs.
- `code-quality` — surgical edits after writing.

## Attribution

Adapted from [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail)
(MIT). The 7-rung ladder is verbatim from the upstream `SKILL.md`.
