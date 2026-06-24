#!/usr/bin/env bash
# skeleton-setup.sh — Mechanical subcommands for the skeleton-setup skill.
#
# The agent invokes these. Judgment (refuse-empty-draft, license confirmation,
# pre-cleanup offer) is the agent's job — see SKILL.md. This script does
# copy/transform/delete only.
#
# Usage:
#   skeleton-setup.sh --help
#   skeleton-setup.sh --dry-run apply-all
#   skeleton-setup.sh apply-license mit
#   skeleton-setup.sh generate-codeowners
#   skeleton-setup.sh substitute-pi-name my-slug
#   skeleton-setup.sh apply-readme
#   skeleton-setup.sh apply-contributing
#   skeleton-setup.sh apply-security
#   skeleton-setup.sh apply-agents
#   skeleton-setup.sh apply-context
#   skeleton-setup.sh apply-handoff
#   skeleton-setup.sh self-cleanup
#
# The global --dry-run flag must appear before the subcommand. It applies to
# whichever subcommand follows.

set -euo pipefail

# ────────────────────────────── paths ────────────────────────────────────────

# Skill folder = the kill folder. Sibling layout:
#   .agents/skills/skeleton-setup/
#     SKILL.md
#     skeleton-setup.sh     <- this file
#     content/              <- user's draft
#     licenses/             <- 8 SPDX license texts
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Project root is 3 levels up from the script: skeleton-setup/ -> .agents/skills/ -> .agents/ -> root
ROOT="$(cd "$SKILL_DIR/../../.." && pwd)"
CONTENT_DIR="$SKILL_DIR/content"
LICENSES_DIR="$SKILL_DIR/licenses"
SELF="$SKILL_DIR/skeleton-setup.sh"
SKILL_MD="$SKILL_DIR/SKILL.md"

# ──────────────────────────── flag parsing ───────────────────────────────────

DRY_RUN=0
SUBCMD=""
SUBCMD_ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --help|-h)
            SUBCMD="__help__"
            shift
            ;;
        --*)
            echo "skeleton-setup: unknown flag: $1" >&2
            echo "Run with --help for usage." >&2
            exit 64
            ;;
        *)
            SUBCMD="$1"
            shift
            SUBCMD_ARGS=("$@")
            break
            ;;
    esac
done

# ─────────────────────── idempotency guard (skipped for self-cleanup) ────────

guard_skill_present() {
    if [[ ! -f "$SKILL_MD" ]]; then
        cat >&2 <<EOF
skeleton-setup: error — skill already consumed or skeleton incomplete.

This script is a one-shot. The skill folder .agents/skills/skeleton-setup/
is removed after a successful run. If you want to re-run setup, start from
a fresh clone of the skeleton repo.
EOF
        exit 2
    fi
}

# ──────────────────────────── license map ────────────────────────────────────
# SPDX id (what content/LICENSE contains) -> canonical file in licenses/
declare -A LICENSE_MAP=(
    [mit]="MIT.txt"
    [apache-2.0]="Apache-2.0.txt"
    [bsd-3-clause]="BSD-3-Clause.txt"
    [mpl-2.0]="MPL-2.0.txt"
    [gpl-3.0]="GPL-3.0-only.txt"
    [agpl-3.0]="AGPL-3.0-only.txt"
    [lgpl-3.0]="LGPL-3.0-only.txt"
    [unlicense]="Unlicense.txt"
)

# ────────────────────────────── helpers ──────────────────────────────────────

log() { printf 'skeleton-setup: %s\n' "$*"; }

dry_run_only() {
    # Echo the action that would have been taken; never execute.
    printf '  [dry-run] %s\n' "$*"
}

# ─────────────────────────── subcommands ─────────────────────────────────────

cmd_help() {
    cat <<EOF
skeleton-setup.sh — mechanical subcommands for the skeleton-setup skill.

The agent invokes these. Judgment (Q1 empty-draft refusal, Q2 license
confirmation, Q3 pre-cleanup offer) is the agent's job — see SKILL.md.

Usage:
  skeleton-setup.sh [--dry-run] <subcommand> [args...]

Subcommands:
  apply-license <spdx-id>     Copy licenses/<mapped-file> to root LICENSE.
                              Refuses unknown SPDX ids.
  generate-codeowners         Read content/MAINTAINERS.md, write .github/CODEOWNERS.
  substitute-pi-name <slug>   Substitute <project-slug> in .pi/mcp.json + .pi/settings.json.
  apply-readme                Copy content/README.md to root README.md.
  apply-contributing           Copy content/CONTRIBUTING.md to root CONTRIBUTING.md.
  apply-security               Copy content/SECURITY.md to root SECURITY.md.
  apply-agents                Copy content/AGENTS.md to root AGENTS.md.
  apply-context               Copy content/CONTEXT.md to root CONTEXT.md.
  apply-handoff               Copy content/HANDOFF.md to root HANDOFF.md.
  self-cleanup                rm -rf the entire skill folder. Idempotent.
  apply-all                   Discover what's in content/ and call the right
                              subcommands in order. Stops before self-cleanup
                              so the agent can run Q3 (pre-cleanup offer).
  --help, -h                  Print this help.

The --dry-run flag (before the subcommand) prints what would happen without
making any changes.

Exit codes:
  0  success (or successful dry-run)
  2  idempotency guard tripped — skill already consumed
  3  unknown SPDX id in apply-license
  4  content/<file> missing for the requested apply-* subcommand
  64 usage error

See SKILL.md for the agent-driven flow.
EOF
}

cmd_apply_license() {
    local id="${1:-}"
    if [[ -z "$id" ]]; then
        echo "skeleton-setup: apply-license requires an SPDX id" >&2
        echo "Try: skeleton-setup.sh --help" >&2
        exit 64
    fi
    if [[ -n "${LICENSE_MAP[$id]:-}" ]]; then
        local src="$LICENSES_DIR/${LICENSE_MAP[$id]}"
        if [[ $DRY_RUN -eq 1 ]]; then
            dry_run_only "cp $src $ROOT/LICENSE"
            return
        fi
        cp "$src" "$ROOT/LICENSE"
        log "LICENSE <- $src (spdx: $id)"
    elif [[ -f "$LICENSES_DIR/$id" ]]; then
        local src="$LICENSES_DIR/$id"
        if [[ $DRY_RUN -eq 1 ]]; then
            dry_run_only "cp $src $ROOT/LICENSE (direct file ref)"
            return
        fi
        cp "$src" "$ROOT/LICENSE"
        log "LICENSE <- $src (direct file ref)"
    else
        echo "skeleton-setup: unknown SPDX id: \"$id\"" >&2
        echo "Expected one of:" >&2
        for k in "${!LICENSE_MAP[@]}"; do echo "  $k" >&2; done
        echo "Or a direct filename relative to licenses/, e.g. Apache-2.0.txt" >&2
        exit 3
    fi
}

cmd_generate_codeowners() {
    local src="$CONTENT_DIR/MAINTAINERS.md"
    if [[ ! -f "$src" ]]; then
        echo "skeleton-setup: $src not found" >&2
        echo "Drop one GitHub handle per line into content/MAINTAINERS.md and re-run." >&2
        exit 4
    fi
    if [[ $DRY_RUN -eq 1 ]]; then
        dry_run_only "regenerate .github/CODEOWNERS from $src"
        return
    fi
    : > "$ROOT/.github/CODEOWNERS"
    while IFS= read -r line; do
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [[ -z "$line" ]] && continue
        [[ "${line:0:1}" == "#" ]] && continue
        echo "* @${line}" >> "$ROOT/.github/CODEOWNERS"
    done < "$src"
    log ".github/CODEOWNERS regenerated from $src"
}

cmd_substitute_pi_name() {
    local slug="${1:-}"
    if [[ -z "$slug" ]]; then
        echo "skeleton-setup: substitute-pi-name requires a slug arg" >&2
        exit 64
    fi
    if [[ $DRY_RUN -eq 1 ]]; then
        dry_run_only "sed '<project-slug>' -> '$slug' in .pi/mcp.json + .pi/settings.json"
        return
    fi
    for f in "$ROOT/.pi/mcp.json" "$ROOT/.pi/settings.json"; do
        if [[ -f "$f" ]]; then
            sed -i.bak "s/\"<project-slug>\"/\"${slug}\"/g" "$f"
            rm -f "$f.bak"
        fi
    done
    log ".pi/ project name set to '$slug'"
}

cmd_apply_content_file() {
    # $1 = name in content/ (e.g. README.md), $2 = destination path under ROOT
    local name="$1"
    local dest="$2"
    local src="$CONTENT_DIR/$name"
    if [[ ! -f "$src" ]]; then
        echo "skeleton-setup: $src not found" >&2
        echo "Drop $name into content/ and re-run, or omit this subcommand." >&2
        exit 4
    fi
    if [[ $DRY_RUN -eq 1 ]]; then
        dry_run_only "cp $src $ROOT/$dest"
        return
    fi
    cp "$src" "$ROOT/$dest"
    log "$dest <- $src"
}

cmd_apply_readme() {
    # When no content/README.md is provided, write a minimal placeholder
    # instead of leaving the skeleton README (oss-starter advertisement) in place.
    local src="$CONTENT_DIR/README.md"
    if [[ -f "$src" ]]; then
        if [[ $DRY_RUN -eq 1 ]]; then
            dry_run_only "cp $src $ROOT/README.md"
            return
        fi
        cp "$src" "$ROOT/README.md"
        log "README.md <- $src"
    else
        if [[ $DRY_RUN -eq 1 ]]; then
            dry_run_only "write placeholder README.md (no content/README.md)"
            return
        fi
        printf '# <!-- TODO: replace with your project README -->\n' > "$ROOT/README.md"
        log "README.md <- placeholder (no content/README.md provided)"
    fi
}

cmd_self_cleanup() {
    if [[ ! -d "$SKILL_DIR" ]]; then
        log "skill folder already gone — nothing to do"
        return
    fi
    if [[ $DRY_RUN -eq 1 ]]; then
        dry_run_only "rm -rf $SKILL_DIR"
        return
    fi
    # Fix AGENTS.md reference to the now-deleted skill folder.
    local agents_md="$ROOT/AGENTS.md"
    if [[ -f "$agents_md" ]]; then
        # Replace the stale skeleton-setup content/ path with a generic reference.
        if grep -q 'skeleton-setup/content/PI_PROJECT_NAME' "$agents_md"; then
            sed -i.bak 's|set \.agents/skills/skeleton-setup/content/PI_PROJECT_NAME|provide content/PI_PROJECT_NAME when running the skeleton-setup skill|' "$agents_md"
            rm -f "$agents_md.bak"
        fi
    fi
    rm -rf "$SKILL_DIR"
    log "skill folder removed: $SKILL_DIR"
}

cmd_apply_all() {
    # Discover what's in content/ and call the right subcommands in order.
    # Stops before self-cleanup so the agent can run Q3.
    log "apply-all: discovering content/ and applying"
    local applied=0
    local skipped=0
    local warnings=0
    # README: always apply (placeholder if no content/)
    cmd_apply_readme
    applied=$((applied + 1))
    if [[ -f "$CONTENT_DIR/LICENSE" ]]; then
        local id
        id="$(tr -d '[:space:]' < "$CONTENT_DIR/LICENSE")"
        cmd_apply_license "$id"
        applied=$((applied + 1))
    else
        skipped=$((skipped + 1))
    fi
    if [[ -f "$CONTENT_DIR/AGENTS.md" ]]; then
        cmd_apply_content_file "AGENTS.md" "AGENTS.md"
        applied=$((applied + 1))
    else
        skipped=$((skipped + 1))
    fi
    if [[ -f "$CONTENT_DIR/CONTEXT.md" ]]; then
        cmd_apply_content_file "CONTEXT.md" "CONTEXT.md"
        applied=$((applied + 1))
    else
        skipped=$((skipped + 1))
    fi
    if [[ -f "$CONTENT_DIR/HANDOFF.md" ]]; then
        cmd_apply_content_file "HANDOFF.md" "HANDOFF.md"
        applied=$((applied + 1))
    else
        skipped=$((skipped + 1))
    fi
    if [[ -f "$CONTENT_DIR/CONTRIBUTING.md" ]]; then
        cmd_apply_content_file "CONTRIBUTING.md" "CONTRIBUTING.md"
        applied=$((applied + 1))
    else
        skipped=$((skipped + 1))
    fi
    if [[ -f "$CONTENT_DIR/SECURITY.md" ]]; then
        cmd_apply_content_file "SECURITY.md" "SECURITY.md"
        applied=$((applied + 1))
    else
        skipped=$((skipped + 1))
    fi
    if [[ -f "$CONTENT_DIR/MAINTAINERS.md" ]]; then
        cmd_generate_codeowners
        applied=$((applied + 1))
    else
        skipped=$((skipped + 1))
    fi
    if [[ -f "$CONTENT_DIR/PI_PROJECT_NAME" ]]; then
        local slug
        slug="$(tr -d '[:space:]' < "$CONTENT_DIR/PI_PROJECT_NAME")"
        cmd_substitute_pi_name "$slug"
        applied=$((applied + 1))
    else
        warnings=$((warnings + 1))
        log "WARNING: PI_PROJECT_NAME not in content/ — .pi/ project field left as placeholder"
    fi
    # Ensure CLAUDE.md -> AGENTS.md symlink exists.
    if [[ ! -L "$ROOT/CLAUDE.md" ]]; then
        if [[ $DRY_RUN -eq 1 ]]; then
            dry_run_only "recreate CLAUDE.md -> AGENTS.md symlink"
        else
            rm -f "$ROOT/CLAUDE.md"
            ln -s AGENTS.md "$ROOT/CLAUDE.md"
            log "CLAUDE.md -> AGENTS.md symlink (re)created"
        fi
    fi
    log "apply-all: $applied applied, $skipped skipped (no content/ file), ${warnings} warning(s). Run Q3 (pre-cleanup offer) before invoking self-cleanup."
}

# ────────────────────────────── main ─────────────────────────────────────────

case "$SUBCMD" in
    __help__|"")            cmd_help ;;
    apply-license)          guard_skill_present; cmd_apply_license "${SUBCMD_ARGS[@]:-}" ;;
    generate-codeowners)    guard_skill_present; cmd_generate_codeowners ;;
    substitute-pi-name)     guard_skill_present; cmd_substitute_pi_name "${SUBCMD_ARGS[@]:-}" ;;
    apply-readme)           guard_skill_present; cmd_apply_readme ;;
    apply-contributing)     guard_skill_present; cmd_apply_content_file "CONTRIBUTING.md" "CONTRIBUTING.md" ;;
    apply-security)         guard_skill_present; cmd_apply_content_file "SECURITY.md" "SECURITY.md" ;;
    apply-agents)           guard_skill_present; cmd_apply_content_file "AGENTS.md" "AGENTS.md" ;;
    apply-context)          guard_skill_present; cmd_apply_content_file "CONTEXT.md" "CONTEXT.md" ;;
    apply-handoff)          guard_skill_present; cmd_apply_content_file "HANDOFF.md" "HANDOFF.md" ;;
    self-cleanup)           cmd_self_cleanup ;;   # guard intentionally skipped: re-runnable
    apply-all)              guard_skill_present; cmd_apply_all ;;
    *)
        echo "skeleton-setup: unknown subcommand: ${SUBCMD:-<none>}" >&2
        echo "Run with --help for usage." >&2
        exit 64
        ;;
esac
