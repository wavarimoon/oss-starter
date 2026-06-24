---
name: gold-standard
description: Project coding standard. Universal principles apply to every project regardless of language. Stack-specific rules live in the marked section at the bottom and are filled in when the project adopts a toolchain.
---

# Gold Standard

The project's coding standard. Universal principles (§ below) apply to every project. Stack-specific rules live in the marked section at the bottom and are filled in when the project adopts a toolchain.

## Universal principles

These apply regardless of language or framework.

- **Before you write, ask the ladder.** See the `ponytail` skill — does this need to exist? Is it already in the codebase? Does stdlib do it? Is there a one-line version? The post-write rules below apply *after* the ladder.
- **Read before edit.** Open the file. Read enough to understand the surrounding code. Then edit. Never edit blind.
- **No premature abstraction.** Three call sites minimum before extracting a helper. Two duplicates are cheaper than the wrong abstraction.
- **Functions do one thing.** If `and` appears in the function name, split it.
- **Names describe *what*, not *how*.** `getUserById`, not `queryUsersTableByPrimaryKey`. `retry`, not `doExponentialBackoffWithJitter`.
- **Errors are values, not control flow.** Every public function's error path is documented. Either handle, log, or rethrow — never swallow.
- **No silent catches.** A bare `catch {}` is a bug report waiting to happen.
- **Tests describe behavior, not implementation.** If the test breaks when you refactor without changing behavior, the test is wrong.
- **Stop-and-ask triggers** (see `AGENTS.md`): new dependencies, schema/auth/crypto changes, replacing existing patterns, 5+ file edits, adding vendor directories.

## Architecture

### Layer discipline

Code flows one direction. Define your project's direction here:

```
[Presentation] → [Business Logic] → [Data Access]
```

Examples:
- **Web app:** UI Components → Hooks/Services → API/Database
- **CLI:** Commands → Core Logic → File System/Network
- **Library:** Public API → Internal Modules → Primitives

**Rules:**
- Lower layers never import from higher layers
- Shared types can be imported anywhere
- When in doubt, dependency points inward (toward business logic)

### Feature communication

When features interact, use **typed contracts**, not ad-hoc imports.

**The Shared Data Rule:**
If two components need the same data, they use the **same hook/function**, not parallel implementations.

```ts
// ❌ Bad: Two components fetching data independently
function UserList() { const users = fetchUsers(); ... }
function UserStats() { const users = fetchUsers(); ... }

// ✅ Good: Shared data fetching
function useUsers() { return fetchUsers(); }
```

**The Contract Rule:**
Features communicate through defined interfaces, not internal imports.

```ts
// ❌ Bad: Feature A importing Feature B's internal function
import { processPayment } from '@/features/billing/internal';

// ✅ Good: Feature A uses Feature B's public API
const processPayment = useBilling().processPayment;
```

**Why this matters:** Without these rules, every feature creates its own data fetching and processing — leading to duplication, inconsistency, and tight coupling.

### State management

Use this decision tree when choosing where to store state:

```
Is it local to one component? → Local state
Is it shared across 2-3 components? → Lift state up or context
Is it global and rarely changes? → Context/config
Is it global and changes frequently? → State manager
Is it server data? → Data fetching library
Is it URL-relevant? → URL parameters
```

**Key principle:** Prefer the simplest solution that works. Don't reach for a state manager when lifting state up suffices.

## Code quality

### Error handling

**Frontend:**
- Catch at the boundary (error boundaries, try/catch in handlers)
- Display user-friendly messages
- Log technical details for debugging

**Backend/API:**
- Validate inputs at the top of the function
- Return early on errors
- Don't nest `if` blocks more than 2 levels deep
- Use typed errors, not generic `Error` with string messages

```ts
// ✅ Good: Fail fast, return early
async function createUser(args) {
  if (!args.email) throw new ValidationError("Email required");
  if (!isValidEmail(args.email)) throw new ValidationError("Invalid email");
  
  // ... main logic
}
```

### Testing scope

**What to test:**
- Business logic and pure functions
- User interactions (clicks, form submissions)
- Edge cases and error paths
- Integration between components

**What NOT to test:**
- Framework internals (React, Django, etc.)
- Third-party libraries (assume they work)
- Style/CSS (unless visual regression testing)
- Trivial getters/setters

**Rule:** If the test breaks when you refactor without changing behavior, the test is wrong.

## Before you commit

Ask yourself:

1. **Would a new team member understand this in 30 seconds?** If not, simplify or add a comment.
2. **Did I violate the layer dependency direction?** Check your imports.
3. **Is there a file I should split?** (See `code-quality` skill for size thresholds)

If yes to any, fix it before committing.

## Enforcement

This standard is enforced by:

1. **This skill** — loaded before every AI session.
2. **CI gates** — lint, type-check, tests (add project-specific commands below).
3. **Code review** — PR reviewer checks against this document.
4. **Pre-commit hooks** — optional but recommended.

<!-- Add project-specific CI commands here:
- `npm run lint`
- `npm run typecheck`
- `npm test`
-->

## Stack-specific

<!-- Fill in when the project adopts a toolchain.

Categories to fill in:
  - Language + runtime + package manager
  - Lint + format + test runner
  - File naming, file-size limits, module structure
  - Import order, error model, logging, state management
  - Abstraction patterns, connection patterns

Until filled in, defer to:
  - The chosen language's community standard (PEP 8, Effective Go, etc.)
  - The formatter config once it's added
  - The four other skills in `.agents/skills/` (plan-feature, planning-philosophy, tdd, code-quality)
-->

## How to evolve this standard

Propose changes via PR. Standards that aren't enforced rot — if a rule is universally ignored, it's wrong, and the standard should change rather than the codebase fighting it.
