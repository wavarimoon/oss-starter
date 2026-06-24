---
name: code-quality
description: TDD and code-quality discipline. Surgical edits, blast-radius, behavior-focused tests. Project-agnostic.
---

# Code Quality

## Principles

1. TDD by default. See `tdd/SKILL.md`.
2. Surgical edits. Reviewable in one pass. Don't bundle unrelated changes.
3. Blast-radius awareness. Grep for callers of shared components before editing.
4. Behavior-focused tests. Test what the system does, not how.
5. Halt on stop-and-ask triggers (see AGENTS.md).

## What this skill does NOT define

File-size limits, naming, formatting, import order. Those belong in `gold-standard` once the language is chosen.
