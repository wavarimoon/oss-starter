---
name: gold-standard
description: Project coding standard. Universal principles apply to every project regardless of language. Stack-specific rules live in the marked section at the bottom and are filled in when the project adopts a toolchain. Examples are illustrative — principles are independent of the language shown.
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

This generalizes to any project shape:
- **Web app:** Routes/Components → Services/Hooks → API/Database
- **CLI:** Commands → Core Logic → File System/Network
- **Library:** Public API → Internal Modules → Primitives
- **Service:** Handlers → Domain Logic → Storage/External APIs

**Rules:**
- Lower layers never import from higher layers
- Shared types can be imported anywhere
- When in doubt, dependency points inward (toward business logic)

### Feature communication

When features interact, use **typed contracts**, not ad-hoc imports.

**The Shared Data Rule:**
If two consumers need the same data, they use the **same accessor**, not parallel implementations. The accessor might be a function, a hook, a service method, or a module export — the principle is that there is one canonical way to get that data.

**The Contract Rule:**
Features communicate through defined interfaces, not internal imports. A feature's public API is its contract with the rest of the system.

**Why this matters:** Without these rules, every feature creates its own data fetching and processing — leading to duplication, inconsistency, and tight coupling.

### State management (when applicable)

Use this decision tree when choosing where to store state:

```
Is it local to one consumer? → Keep it local
Is it shared across a few consumers? → Lift to nearest common ancestor
Is it global and rarely changes? → Configuration / context
Is it global and changes frequently? → Dedicated state store
Is it server data? → Server, cached locally
Is it ephemeral but shareable? → URL / arguments
```

**Key principle:** Prefer the simplest solution that works. Don't reach for a global store when lifting state one level up suffices.

## Code quality

### Error handling

**API / service boundary:**
- Catch at the boundary (routers, command handlers, service entry points)
- Return user-visible messages from the boundary
- Log technical details for debugging

**Internal logic:**
- Validate inputs at the top of the function
- Return early on errors
- Don't nest more than 2 levels deep
- Use typed errors, not generic `Error` with string messages

```ts
// ✅ Good: Fail fast, return early (language doesn't matter)
async function createUser(args) {
  if (!args.email) throw new ValidationError("Email required");
  if (!isValidEmail(args.email)) throw new ValidationError("Invalid email");
  // ... main logic
}
```

### Testing scope

**What to test:**
- Business logic and pure functions
- Edge cases and error paths
- Integration between modules/systems

**What NOT to test:**
- Framework/standard-library internals
- Third-party libraries (assume they work)
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
