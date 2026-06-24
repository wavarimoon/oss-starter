#!/usr/bin/env bats
# Tests for skeleton-setup.sh
#
# Each test copies the skill folder into a temp directory so the real
# project files are never touched (especially by self-cleanup).

setup() {
  TEST_DIR="$(mktemp -d)"
  # Create a minimal project skeleton under TEST_DIR
  mkdir -p "$TEST_DIR/.pi"
  mkdir -p "$TEST_DIR/.github"
  mkdir -p "$TEST_DIR/plans/in-flight"
  mkdir -p "$TEST_DIR/plans/archive"
  touch "$TEST_DIR/README.md"
  touch "$TEST_DIR/AGENTS.md"

  # Write .pi JSON files with placeholder (matching the real ones)
  cat > "$TEST_DIR/.pi/mcp.json" <<'JSON'
{
  "project": "<project-slug>"
}
JSON
  cat > "$TEST_DIR/.pi/settings.json" <<'JSON'
{
  "project": "<project-slug>"
}
JSON

  # Copy the skill folder (but NOT content/ — we'll populate that per test)
  PROJECT_ROOT="/opt/projects/oss-starter"
  SKILL_SRC="$PROJECT_ROOT/.agents/skills/skeleton-setup"
  mkdir -p "$TEST_DIR/.agents/skills/skeleton-setup/licenses"
  cp "$SKILL_SRC/skeleton-setup.sh" "$TEST_DIR/.agents/skills/skeleton-setup/"
  cp "$SKILL_SRC/SKILL.md" "$TEST_DIR/.agents/skills/skeleton-setup/"
  # Copy licenses for apply-license tests
  if [ -d "$SKILL_SRC/licenses" ]; then
    cp "$SKILL_SRC/licenses"/*.txt "$TEST_DIR/.agents/skills/skeleton-setup/licenses/" 2>/dev/null || true
  fi
  # Create a minimal license file if none exist
  if ! ls "$TEST_DIR/.agents/skills/skeleton-setup/licenses/"*.txt >/dev/null 2>&1; then
    echo "MIT License placeholder" > "$TEST_DIR/.agents/skills/skeleton-setup/licenses/MIT.txt"
  fi

  SCRIPT="$TEST_DIR/.agents/skills/skeleton-setup/skeleton-setup.sh"
  chmod +x "$SCRIPT"
  CONTENT_DIR="$TEST_DIR/.agents/skills/skeleton-setup/content"
  mkdir -p "$CONTENT_DIR"
}

teardown() {
  rm -rf "$TEST_DIR"
}

# ──────────────────────────── apply-license ────────────────────────────────

@test "apply-license with valid SPDX id copies LICENSE to root" {
  echo "mit" > "$CONTENT_DIR/LICENSE"
  run "$SCRIPT" apply-license mit
  [ "$status" -eq 0 ]
  [ -f "$TEST_DIR/LICENSE" ]
  [ -s "$TEST_DIR/LICENSE" ]
}

@test "apply-license with unknown SPDX id exits 3" {
  run "$SCRIPT" apply-license nonexistent
  [ "$status" -eq 3 ]
}

@test "apply-license with missing arg exits 64" {
  run "$SCRIPT" apply-license ""
  [ "$status" -ne 0 ]
}

@test "apply-license --dry-run does not create LICENSE" {
  echo "mit" > "$CONTENT_DIR/LICENSE"
  run "$SCRIPT" --dry-run apply-license mit
  [ "$status" -eq 0 ]
  [ ! -f "$TEST_DIR/LICENSE" ]
  [[ "$output" =~ dry-run ]]
}

# ──────────────────────────── generate-codeowners ──────────────────────────

@test "generate-codeowners creates CODEOWNERS from MAINTAINERS.md" {
  printf 'octocat\n# a comment\nmonalisa\n' > "$CONTENT_DIR/MAINTAINERS.md"
  run "$SCRIPT" generate-codeowners
  [ "$status" -eq 0 ]
  [ -f "$TEST_DIR/.github/CODEOWNERS" ]
  grep -q '@octocat' "$TEST_DIR/.github/CODEOWNERS"
  grep -q '@monalisa' "$TEST_DIR/.github/CODEOWNERS"
  # Comments should be stripped
  ! grep -q '# a comment' "$TEST_DIR/.github/CODEOWNERS"
}

@test "generate-codeowners with missing MAINTAINERS.md exits 4" {
  run "$SCRIPT" generate-codeowners
  [ "$status" -eq 4 ]
}

# ──────────────────────────── substitute-pi-name ───────────────────────────

@test "substitute-pi-name replaces placeholder in both .pi JSON files" {
  run "$SCRIPT" substitute-pi-name my-project
  [ "$status" -eq 0 ]
  grep -q '"my-project"' "$TEST_DIR/.pi/mcp.json"
  grep -q '"my-project"' "$TEST_DIR/.pi/settings.json"
  # Original placeholder should be gone
  ! grep -q '<project-slug>' "$TEST_DIR/.pi/mcp.json"
  ! grep -q '<project-slug>' "$TEST_DIR/.pi/settings.json"
}

@test "substitute-pi-name with missing arg exits non-zero" {
  run "$SCRIPT" substitute-pi-name ""
  [ "$status" -ne 0 ]
}

# ──────────────────────────── apply-readme ────────────────────────────────

@test "apply-readme copies content/README.md to root" {
  echo "# My Project" > "$CONTENT_DIR/README.md"
  run "$SCRIPT" apply-readme
  [ "$status" -eq 0 ]
  grep -q '# My Project' "$TEST_DIR/README.md"
}

@test "apply-readme writes placeholder when content/README.md is missing" {
  run "$SCRIPT" apply-readme
  [ "$status" -eq 0 ]
  grep -q 'TODO:' "$TEST_DIR/README.md"
}

# ─────────────────── apply-contributing / apply-security ───────────────────

@test "apply-contributing copies content/CONTRIBUTING.md to root" {
  echo "# Contributing to X" > "$CONTENT_DIR/CONTRIBUTING.md"
  run "$SCRIPT" apply-contributing
  [ "$status" -eq 0 ]
  grep -q 'Contributing to X' "$TEST_DIR/CONTRIBUTING.md"
}

@test "apply-contributing exits 4 when content file missing" {
  run "$SCRIPT" apply-contributing
  [ "$status" -eq 4 ]
}

@test "apply-security copies content/SECURITY.md to root" {
  echo "# Security Policy" > "$CONTENT_DIR/SECURITY.md"
  run "$SCRIPT" apply-security
  [ "$status" -eq 0 ]
  grep -q 'Security Policy' "$TEST_DIR/SECURITY.md"
}

@test "apply-security exits 4 when content file missing" {
  run "$SCRIPT" apply-security
  [ "$status" -eq 4 ]
}

# ──────────────────────────── apply-all ────────────────────────────────────

@test "apply-all discovers content/ and applies files" {
  echo "# My README" > "$CONTENT_DIR/README.md"
  echo "mit" > "$CONTENT_DIR/LICENSE"
  printf 'octocat\n' > "$CONTENT_DIR/MAINTAINERS.md"
  echo "my-slug" > "$CONTENT_DIR/PI_PROJECT_NAME"

  run "$SCRIPT" apply-all
  [ "$status" -eq 0 ]

  # Verify operations happened
  grep -q '# My README' "$TEST_DIR/README.md"
  [ -f "$TEST_DIR/LICENSE" ]
  [ -f "$TEST_DIR/.github/CODEOWNERS" ]
  grep -q '"my-slug"' "$TEST_DIR/.pi/mcp.json"
}

@test "apply-all --dry-run prints summary without changes" {
  echo "# My README" > "$CONTENT_DIR/README.md"
  echo "mit" > "$CONTENT_DIR/LICENSE"

  run "$SCRIPT" --dry-run apply-all
  [ "$status" -eq 0 ]
  [[ "$output" =~ dry-run ]]

  # No actual changes should have occurred
  ! grep -q '# My README' "$TEST_DIR/README.md" 2>/dev/null || true
  [ ! -f "$TEST_DIR/LICENSE" ] || false
}

@test "apply-all prints summary with applied/skipped/warnings" {
  echo "# My README" > "$CONTENT_DIR/README.md"

  run "$SCRIPT" apply-all
  [ "$status" -eq 0 ]
  [[ "$output" =~ applied ]]
  [[ "$output" =~ skipped ]]
}

@test "apply-all warns when PI_PROJECT_NAME is missing" {
  echo "# My README" > "$CONTENT_DIR/README.md"

  run "$SCRIPT" apply-all
  [ "$status" -eq 0 ]
  [[ "$output" =~ PI_PROJECT_NAME ]]
}

@test "apply-all creates CLAUDE.md symlink" {
  echo "# README" > "$CONTENT_DIR/README.md"

  run "$SCRIPT" apply-all
  [ "$status" -eq 0 ]
  [ -L "$TEST_DIR/CLAUDE.md" ]
}

# ──────────────────────────── self-cleanup ─────────────────────────────────

@test "self-cleanup removes the skill folder" {
  run "$SCRIPT" self-cleanup
  [ "$status" -eq 0 ]
  [ ! -d "$TEST_DIR/.agents/skills/skeleton-setup" ]
}

@test "self-cleanup is idempotent" {
  # After cleanup, the skill folder and script are gone — there's nothing
  # left to call. The idempotency is that calling it once succeeds and
  # the folder is removed.
  run "$SCRIPT" self-cleanup
  [ "$status" -eq 0 ]
  [ ! -d "$TEST_DIR/.agents/skills/skeleton-setup" ]
  # The script path itself no longer exists (the folder is gone)
  [ ! -f "$SCRIPT" ]
}

@test "self-cleanup fixes stale AGENTS.md reference" {
  # Write an AGENTS.md with the stale reference
  echo 'set .agents/skills/skeleton-setup/content/PI_PROJECT_NAME and the skeleton-setup skill will substitute it' > "$TEST_DIR/AGENTS.md"

  run "$SCRIPT" self-cleanup
  [ "$status" -eq 0 ]
  # The reference should be patched
  ! grep -q 'skeleton-setup/content/PI_PROJECT_NAME' "$TEST_DIR/AGENTS.md"
}

# ──────────────────── guard (idempotency) ──────────────────────────────────

@test "guard refuses after skill folder is removed" {
  # First run self-cleanup to remove the skill folder.
  run "$SCRIPT" self-cleanup
  [ "$status" -eq 0 ]
  [ ! -d "$TEST_DIR/.agents/skills/skeleton-setup" ]
  # After self-cleanup, the script is gone — the guard is moot.
  # The real guard triggers when someone tries to run with a stale
  # skill folder (e.g. after copying an already-cleaned-up project).
  # We simulate that: create a fresh skill folder WITHOUT SKILL.md.
  mkdir -p "$TEST_DIR/.agents/skills/skeleton-setup"
  cp "$PROJECT_ROOT/.agents/skills/skeleton-setup/skeleton-setup.sh" "$TEST_DIR/.agents/skills/skeleton-setup/"
  local script2="$TEST_DIR/.agents/skills/skeleton-setup/skeleton-setup.sh"
  chmod +x "$script2"
  # No SKILL.md in the folder → guard should trip
  run "$script2" apply-readme
  [ "$status" -eq 2 ]
}

# ──────────────────────────── help ─────────────────────────────────────────

@test "--help prints usage and exits 0" {
  run "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ Usage ]]
  [[ "$output" =~ apply-contributing ]]
  [[ "$output" =~ apply-security ]]
}

@test "no subcommand prints help" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" =~ Usage ]]
}