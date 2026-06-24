---
name: tdd
description: Strict Test-Driven Development using Red-Green-Refactor cycles. Use when implementing features, fixing bugs, or when user invokes /tdd. Guides through failing test first, minimal code to pass, then refactor. Supports Vitest, pytest, and Go testing.
---

# TDD Skill — Red-Green-Refactor

You are guiding the developer through strict Test-Driven Development. You write code directly to the real files — the user can always undo with git. Pause only when the user's input is needed, not at every step.

## Phase 1: Setup

1. Determine the input type:
   - **If the input is a file path** (ends in `.md`, `.txt`, or exists on disk): read the plan file.
   - **If the input is an inline description** (e.g., `"add JWT authentication with refresh tokens"`): use it directly as the feature specification. Ask clarifying questions only if the description is too vague to decompose into increments.
2. Detect the language and test framework from the project:
   - TypeScript → vitest
   - Python → pytest
   - Go → testing (stdlib)
3. Break the feature into small, testable increments.
4. Present the increment list to the user for approval.

## Phase 2: TDD Loop

For each increment, follow Red-Green-Refactor strictly.

### RED — Write a Failing Test

1. Write the failing test directly to the real test file.
2. Run the test using the appropriate runner.
3. Confirm the test **fails**. If it passes unexpectedly, stop and investigate.
4. Pause: "RED: test fails as expected. Ready for GREEN?"

### GREEN — Write Minimal Code to Pass

5. Write the **minimal** production code to make the failing test pass.
6. Run **all** tests (not just the new one).
7. If all tests **pass**, move to REFACTOR.
8. If any test **fails**, show failure and ask user.

### REFACTOR — Improve the Code

9. Review code. If refactoring opportunities exist, apply them and run all tests.
10. If no refactoring needed, move on.
11. If refactoring causes failure, revert and discuss.

### NEXT

12. Summarize what was added.
13. Move to next increment.

## Phase 3: Wrap-up

After all increments complete:
1. Summarize what was built
2. Note final test count and all-passing status
3. Suggest remaining work

## Rules

- Write directly to real files (user has git for undo)
- Pause only after RED confirms failure and when something goes wrong
- Run full test suite at GREEN and REFACTOR steps
- Keep tests behavior-focused, not implementation-focused
- Simplest case first
- One assertion per test when possible
- Follow existing project conventions
