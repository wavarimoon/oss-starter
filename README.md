# oss-starter

> A portable open-source project starter. Self-maintaining documentation. Agent skills for AI coding assistants. One-shot self-cleaning setup.

**oss-starter** is a generic, domain-agnostic starter for open-source projects. You clone it, drop your project context into `.agents/skills/skeleton-setup/content/`, and the `skeleton-setup` skill materializes your project — replacing placeholders, picking a license, generating `CODEOWNERS`, and removing itself in one `rm -rf`.

## What's in the box

- **Self-maintaining documentation** — `oss-gate` enforces the OSS contract on every PR. Add your own doc-drift detection as a workflow once you adopt a toolchain.
- **Agent skills** — `plan-feature`, `planning-philosophy`, `tdd`, `code-quality`, `gold-standard`, `ponytail`, and `skeleton-setup` are auto-loaded by AI coding assistants (Pi, Claude Code, Cursor, etc.).
- **One-shot setup** — drop your context, run the skill, the skill folder disappears. Nothing to clean up after.
- **8 SPDX licenses included** — `mit`, `apache-2.0`, `bsd-3-clause`, `mpl-2.0`, `gpl-3.0`, `agpl-3.0`, `lgpl-3.0`, `unlicense`.
- **Domain-agnostic** — works for libraries, services, frameworks, anything.

## Quick start (use as a starter for a new project)

```sh
git clone https://github.com/wavarimoon/oss-starter.git my-project
cd my-project

# Read the input contract
cat .agents/skills/skeleton-setup/INPUT_GUIDE.md

# Drop your project context into content/
mkdir -p .agents/skills/skeleton-setup/content
# Add README.md, LICENSE choice, etc. — see INPUT_GUIDE.md for the full contract

# Open your AI coding assistant and ask it to run the skeleton-setup skill.
# The agent handles Q1 (refuse if empty), Q2 (license confirmation), Q3 (pre-cleanup offer).
```

## Quick start (use oss-starter's own skills in an existing project)

You don't have to use the whole starter. You can copy individual skills into your existing project:

```sh
# Copy one skill
cp -r oss-starter/.agents/skills/tdd your-project/.agents/skills/

# Or cherry-pick the workflow
cp oss-starter/.github/workflows/oss-gate.yml your-project/.github/workflows/
```

## Layout

```
.
├── AGENTS.md                       ← cross-harness AI agent constitution
├── CLAUDE.md → AGENTS.md           ← symlink for Claude Code
├── README.md, CONTRIBUTING.md,
│   SECURITY.md, CODE_OF_CONDUCT.md ← GitHub community-profile files
├── LICENSE                         ← Apache-2.0 (this skeleton's own license)
├── HANDOFF.md, CONTEXT.md          ← session state + domain glossary templates
├── .gitignore
├── .pi/                            ← Pi harness config (MCP, providers)
├── .github/
│   ├── workflows/
│   │   └── oss-gate.yml           ← file-presence checks on every PR
│   ├── ISSUE_TEMPLATE/
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── CODEOWNERS
├── .agents/
│   └── skills/
│       ├── skeleton-setup/         ← KILL FOLDER (consumed on first run)
│       │   ├── SKILL.md
│       │   ├── INPUT_GUIDE.md
│       │   ├── licenses/           ← 8 SPDX license texts
│       │   └── skeleton-setup.sh   ← mechanical subcommands
│       ├── plan-feature/
│       ├── planning-philosophy/
│       ├── tdd/
│       ├── code-quality/
│       ├── gold-standard/
│       └── ponytail/
└── plans/
    ├── README.md
    ├── archive.sh
    ├── todo/
    │   └── <slug>/
    │       ├── v1.md
    │       ├── v2.md
    │       └── research.md
    └── archive/
        └── <slug>.md
```

## Contributing to oss-starter itself

oss-starter is itself an open-source project. PRs welcome. See [`CONTRIBUTING.md`](./CONTRIBUTING.md) for the contribution surface, "first PR" ideas, and the merge discipline.

The `oss-gate` workflow runs on every PR and on merge to `main`. Add additional workflows (lint, test, build) as your project adopts a toolchain.

## License

Apache-2.0. See [`LICENSE`](./LICENSE). Consumers of this starter can pick any of the 8 SPDX licenses bundled in `.agents/skills/skeleton-setup/licenses/` — the choice is theirs, made at setup time.

## Acknowledgments

- The `ponytail` skill is adapted from [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) (MIT).
- The 8 license texts in `.agents/skills/skeleton-setup/licenses/` are verbatim from the [SPDX License List](https://spdx.org/licenses/).
