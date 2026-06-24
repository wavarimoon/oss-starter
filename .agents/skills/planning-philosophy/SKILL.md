---
name: planning-philosophy
description: Core planning principles — earn the right to act before acting. Extract constraints, read terrain, have an approved plan, carry constraints forward. Use before any non-trivial feature work.
---

# Planning Philosophy

**Earn the right to act before acting.**

## Core Principles

1. **Extract constraints first** — Before exploring code, understand what's non-negotiable
2. **Read the terrain** — Understand existing patterns before designing new ones
3. **Have an approved plan** — No code without explicit user approval
4. **Carry constraints forward** — Every phase checks against hard constraints

## When to apply

- Any work touching 5+ files
- New dependencies
- Schema/auth/architecture changes
- Greenfield features

## What this means in practice

1. **Before exploration:**
   - Ask: "What are the hard constraints?"
   - Read project's AGENTS.md and rules
   - Classify: hard vs soft constraints

2. **Before coding:**
   - Have a written plan (v1 or v2)
   - Have user approval
   - Know your rollback triggers

3. **During execution:**
   - Check each step against constraints
   - If a constraint is violated, STOP
   - If new info surfaces, update plan (don't silently adapt)

## Anti-patterns

- "I'll figure it out as I go" — no, you won't
- Coding before Phase 5 approval
- Ignoring project rules because "this time is different"
- Treating constraints as suggestions
