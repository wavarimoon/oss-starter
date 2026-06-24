# Input Guide — Project Inputs for `skeleton-setup`

> **You are reading this because someone (you, or an AI agent) is about to set up a new project from this skeleton.** This file lives at the skill root (alongside `SKILL.md` and `skeleton-setup.sh`). When the skill runs, the entire skill folder — including this file — is removed in one `rm -rf`. So read it now.
>
> **This file used to live at `content/README.md`.** It was moved out of `content/` so the input folder is purely user space — the script reads whatever is in `content/`, and won't accidentally copy this contract into your project.

`content/` is the **single input surface** between the skeleton and your new project. Drop the files that match what you want your project to be. Anything you don't provide falls back to the skeleton's documented default.

## Before you start: the agent will ask questions

The agent running the skill will:

1. **(Q1) Refuse to run if `content/` is empty.** Drop something first: a project idea, a README draft, a LICENSE choice, screenshots, anything. Once `content/` has at least one file, the agent proceeds.
2. **(Q2) Pause for a license decision** if you didn't put one in `content/LICENSE`. It will recommend one with reasoning and 1-2 alternatives, then wait for you to pick.
3. **(Q3) Before deleting this skill folder**, the agent will warn you, list what's about to be deleted, and offer to keep/relocate specific draft files (e.g. images you put in `content/`).

## Fields you can put in `content/`

| File | Required? | Purpose | If missing |
|---|---|---|---|
| `README.md` | recommended | The project's README. Replaces the skeleton's README. | Placeholder README written |
| `LICENSE` | recommended | One SPDX identifier (lowercase). See `licenses/README.md`. Replaces the skeleton's LICENSE. | Apache-2.0 (skeleton default) |
| `CONTRIBUTING.md` | optional | Your contribution guide. Phase 2.5 rewrites the skeleton's to remove oss-starter framing. | Skeleton CONTRIBUTING.md kept (Phase 2.5 may rewrite) |
| `SECURITY.md` | optional | Your security policy. Phase 2.5 rewrites the skeleton's to replace placeholders. | Skeleton SECURITY.md kept (Phase 2.5 may rewrite) |
| `AGENTS.md` | optional | A project-specific cross-harness AI agent constitution. Replaces the skeleton's generic AGENTS.md. | Skeleton AGENTS.md kept |
| `CONTEXT.md` | optional | A domain glossary for AI sessions. Replaces the skeleton's CONTEXT.md. | Skeleton CONTEXT.md kept |
| `HANDOFF.md` | optional | The project's first session handoff doc. Replaces the skeleton's HANDOFF.md. | Skeleton HANDOFF.md kept |
| `MAINTAINERS.md` | optional | One GitHub handle per line. Becomes `.github/CODEOWNERS`. | Skeleton CODEOWNERS placeholder kept (you must replace `@your-github-handle` manually) |
| `PI_PROJECT_NAME` | optional | A short slug (lowercase, dashes OK). Becomes the Engram project name in `.pi/mcp.json` and `.pi/settings.json`. | `<project-slug>` placeholder kept |
| **anything else** | optional | Images, mockups, reference docs, notes — kept as long as you answer Q3 with "keep these" or "move these" before cleanup. | Deleted with `content/` if you don't flag it. |

## `LICENSE` — the SPDX id format

Drop a single-line file named `LICENSE` containing exactly one of:

```
mit
apache-2.0
bsd-3-clause
mpl-2.0
gpl-3.0
agpl-3.0
lgpl-3.0
unlicense
```

Example:
```
$ cat content/LICENSE
apache-2.0
```

The script maps this id to the canonical text in `licenses/` and writes it to the project's root `LICENSE`.

## `MAINTAINERS.md` — GitHub handles

One handle per line, no `@`. Empty lines and lines starting with `#` are ignored.

Example:
```
# Primary maintainer
octocat
# Backup maintainer
monalisa
```

The script writes:
```
* @octocat
* @monalisa
```

to `.github/CODEOWNERS`.

## `PI_PROJECT_NAME` — Engram slug

A short, URL-safe identifier (lowercase letters, digits, dashes). Example:
```
my-cool-project
```

## Example: a minimal setup

A consumer who just wants the project to exist with Apache-2.0 needs *only* a `content/README.md`. They can skip everything else; the defaults take over.

```
content/
└── README.md          # "My Cool Project\n\nWhat it does.\n"
```

## Example: a fully-specified setup

```
content/
├── README.md          # Full project README
├── LICENSE            # "mit"
├── AGENTS.md          # Project-specific agent constitution
├── CONTEXT.md         # Domain glossary
├── HANDOFF.md         # First session handoff
├── MAINTAINERS.md     # "octocat\nmonalisa\n"
├── PI_PROJECT_NAME    # "my-cool-project"
├── logo.png           # Q3 will offer to move this to assets/logo.png
└── notes.md           # Q3 will offer to keep this or move to docs/
```

## What gets deleted

When the skill finishes, the following are removed (in one `rm -rf`):

- The entire `.agents/skills/skeleton-setup/` folder, which contains:
  - This file (`INPUT_GUIDE.md`)
  - `SKILL.md`
  - `skeleton-setup.sh` (the mechanical script)
  - `licenses/` (8 SPDX license texts + README)
  - `content/` (your draft, unless you answered Q3 to keep/move specific files first)

The skill itself is a one-shot — it cannot be re-run on a generated project. To re-do the setup, start over from the skeleton.
