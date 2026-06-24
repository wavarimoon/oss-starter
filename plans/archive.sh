#!/usr/bin/env bash
# plans/archive.sh — archive an executed plan as a single file.
#
# Usage:
#   ./plans/archive.sh <slug> [one-line outcome]
#
# Example:
#   ./plans/archive.sh my-feature "Added feature X via API; closed #42."
#
# Pre-conditions:
#   - plans/in-flight/<slug>/v2.md exists (the plan was executed)
#   - plans/ROADMAP.md has an "In flight" entry linking to <slug>
#
# What this does (atomic, idempotent):
#   1. Concatenate plans/in-flight/<slug>/{v1,v2,research}.md into
#      plans/archive/<slug>.md (single file, the full audit trail).
#   2. Delete plans/in-flight/<slug>/.
#   3. Flip the ROADMAP.md entry from "In flight" to "Executed"
#      (rewrites the path: in-flight/<slug>/v2.md → archive/<slug>.md).
#   4. Append a one-line entry to HANDOFF.md § Recent decisions.
#
# Idempotent: re-running on an already-archived plan is a noop.

set -euo pipefail

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: $0 <slug> [one-line outcome]" >&2
    echo "Example: $0 my-feature 'Added feature X.'" >&2
    exit 64
fi

slug="$1"
outcome="${2:-Executed. See file for details.}"

root="$(cd "$(dirname "$0")/.." && pwd)"
inflight="$root/plans/in-flight/$slug"
archive="$root/plans/archive/$slug.md"
roadmap="$root/plans/ROADMAP.md"
handoff="$root/HANDOFF.md"

# Idempotency: already archived?
if [ -f "$archive" ] && [ ! -d "$inflight" ]; then
    echo "✓ Plan '$slug' is already archived at $archive" >&2
    echo "  Nothing to do. (Idempotent.)" >&2
    exit 0
fi

# Pre-checks
if [ ! -d "$inflight" ]; then
    echo "✗ No plan folder found at $inflight" >&2
    exit 1
fi

if [ ! -s "$inflight/v2.md" ]; then
    echo "✗ $inflight/v2.md is missing or empty — can't archive an unstarted plan" >&2
    exit 1
fi

mkdir -p "$(dirname "$archive")"

# Step 1: concatenate plan artifacts into a single archive file.
# v2.md is required; v1.md and research.md are optional (a plan may be
# small enough to skip v1 / research and produce only v2).
echo "→ Writing $archive (v2.md is required; v1.md + research.md are optional)"
{
    echo "# $slug"
    echo
    echo "**Outcome:** $outcome"
    echo
    echo "**Archived on:** $(date -u +%Y-%m-%d)"
    echo
    echo "---"
    echo
    if [ -s "$inflight/v1.md" ]; then
        echo "## v1.md (codebase-research-only draft, immutable)"
        echo
        cat "$inflight/v1.md"
        echo
        echo "---"
        echo
    else
        echo "_v1.md not present — plan was small enough to skip the v1 draft._"
        echo
        echo "---"
        echo
    fi
    echo "## v2.md (executable plan, the one we executed from)"
    echo
    cat "$inflight/v2.md"
    echo
    echo "---"
    echo
    if [ -s "$inflight/research.md" ]; then
        echo "## research.md (research findings, 2026-current sources)"
        echo
        cat "$inflight/research.md"
    else
        echo "_research.md not present — no external research was needed._"
    fi
} > "$archive"

# Step 2: remove the in-flight folder
echo "→ Removing $inflight"
rm -rf "$inflight"

# Step 3: remove ROADMAP.md entry from In flight (executed plans now live in
# plans/archive/<slug>.md as the source of truth — ROADMAP only tracks upcoming).
if [ -s "$roadmap" ]; then
    if grep -qF "$slug" "$roadmap"; then
        if awk -v slug="$slug" '
            /^## In flight/{flag=1; next}
            /^## /{flag=0}
            flag && $0 ~ slug {found=1}
            END {exit !found}
        ' "$roadmap"; then
            echo "→ Removing $slug entry from ROADMAP.md § In flight (now in plans/archive/$slug.md)"
            tmp_roadmap=$(mktemp)
            awk -v slug="$slug" '
                /^## In flight/ { inflight=1; print; next }
                /^## / { inflight=0; print; next }
                inflight && $0 ~ slug { next }
                { print }
            ' "$roadmap" > "$tmp_roadmap"
            mv "$tmp_roadmap" "$roadmap"
        else
            echo "✓ $slug already removed from ROADMAP.md § In flight"
        fi
    else
        echo "⚠ $slug not found in ROADMAP.md (already archived?)" >&2
    fi
fi

# Step 4: append to HANDOFF.md § Recent decisions
if [ -s "$handoff" ]; then
    if ! grep -qF "$slug" "$handoff"; then
        echo "→ Appending entry to HANDOFF.md § Recent decisions"
        tmp_handoff=$(mktemp)
        awk -v slug="$slug" -v outcome="$outcome" '
            /^## Recent decisions/ { in_section=1; print; next }
            in_section && /^## / { in_section=0 }
            in_section && NF > 0 && !inserted {
                print
                print "- **Plan archived: " slug "** — " outcome
                inserted = 1
                next
            }
            { print }
            END {
                if (!inserted) {
                    print "<!-- archive.sh: WARNING — could not find Recent decisions section -->"
                }
            }
        ' "$handoff" > "$tmp_handoff"
        mv "$tmp_handoff" "$handoff"
    else
        echo "✓ $slug already mentioned in HANDOFF.md"
    fi
fi

echo
echo "✓ Archive ritual complete."
echo "  Result: plans/archive/$slug.md"
echo "  Reminders:"
echo "  - Verify ROADMAP.md is correct: $roadmap"
echo "  - oss-gate workflow will run on next PR and confirm checks 7-10 are green."