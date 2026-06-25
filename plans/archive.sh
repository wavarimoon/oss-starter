#!/usr/bin/env bash
set -euo pipefail

# Archive a plan from plans/todo/<slug>/ to plans/archive/<slug>.md
#
# Usage: archive.sh [--dry-run] <slug> [outcome]

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  shift
fi

if [[ $# -lt 1 ]]; then
  echo "Usage: archive.sh [--dry-run] <slug> [outcome]" >&2
  exit 1
fi

slug="$1"
outcome="${2:-}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TODO_DIR="$SCRIPT_DIR/todo/$slug"
ARCHIVE_DIR="$SCRIPT_DIR/archive"
ARCHIVE_FILE="$ARCHIVE_DIR/$slug.md"
HANDOFF="$SCRIPT_DIR/../HANDOFF.md"

# --- Idempotency ---
if [[ -f "$ARCHIVE_FILE" ]]; then
  echo "Already archived: $ARCHIVE_FILE" >&2
  exit 0
fi

if [[ ! -d "$TODO_DIR" ]]; then
  echo "No plan found at $TODO_DIR" >&2
  exit 1
fi

# --- Collect parts ---
content=""
for part in v1.md v2.md research.md; do
  file="$TODO_DIR/$part"
  if [[ -f "$file" ]]; then
    content+="# $part"$'\n\n'
    content+="$(cat "$file")"$'\n\n'
    content+='---'$'\n\n'
  fi
done

if [[ -n "$outcome" ]]; then
  content+="# outcome"$'\n\n'
  content+="$outcome"$'\n\n'
  content+='---'$'\n\n'
fi

# --- Dry run ---
if $DRY_RUN; then
  echo "Would create: $ARCHIVE_FILE"
  echo "Would delete: $TODO_DIR"
  echo "Would append to: $HANDOFF"
  echo ""
  echo "Content preview (${#content} chars):"
  echo "$content" | head -20
  exit 0
fi

# --- Write archive (atomic via tmp) ---
mkdir -p "$ARCHIVE_DIR"
tmp=$(mktemp "$ARCHIVE_DIR/.tmp-archive-XXXXXX.md")
printf '%s' "$content" > "$tmp"

# Verify awk produced non-empty output
if [[ ! -s "$tmp" ]]; then
  echo "Error: generated archive content is empty for slug '$slug'" >&2
  rm -f "$tmp"
  exit 1
fi

mv "$tmp" "$ARCHIVE_FILE"
echo "Archived: $ARCHIVE_FILE"

# --- Remove the todo folder ---
rm -rf "$TODO_DIR"
echo "Removed: $TODO_DIR"

# --- Append to HANDOFF.md ---
if [[ -f "$HANDOFF" ]] && ! grep -q "archive/$slug" "$HANDOFF"; then
  tmp_handoff=$(mktemp "${HANDOFF}.tmp-XXXXXX")
  awk -v slug="$slug" '
    /## Recent decisions/ {
      found=1
      print
      next
    }
    found && /^##/ {
      # Hit next section without finding a bullet
      printf "\n- $(date +%F) — Archived plan: %s\n\n", slug
      found=0
    }
    {
      if (found && index($0, slug) > 0) next
      print
    }
    END {
      if (found) {
        printf "- $(date +%F) — Archived plan: %s\n\n", slug
      }
    }
  ' "$HANDOFF" > "$tmp_handoff"

  if [[ -s "$tmp_handoff" ]]; then
    mv "$tmp_handoff" "$HANDOFF"
    echo "Updated: $HANDOFF"
  else
    echo "Error: awk produced empty output for HANDOFF update" >&2
    rm -f "$tmp_handoff"
    exit 1
  fi
fi
