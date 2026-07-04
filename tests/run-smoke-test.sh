#!/usr/bin/env bash
# run-smoke-test.sh — Smoke test list-sessions.sh with fixture status files.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/skills/session-recall/scripts/list-sessions.sh"
FIXTURES="$ROOT/tests/fixtures"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

fail() { echo "FAIL: $1"; exit 1; }
pass() { echo "PASS: $1"; }

[[ -x "$SCRIPT" ]] || fail "Script not executable: $SCRIPT"

# --- Test 1: empty directory ---
export HOME="$TMP_HOME"
mkdir -p "$HOME/.agent-sessions"
out="$(bash "$SCRIPT")"
echo "$out" | grep -q "No sessions found" || fail "empty dir should report no sessions"
pass "empty session directory"

# --- Test 2: fixtures with active + stale ---
cp "$FIXTURES/active-session.md" "$HOME/.agent-sessions/my-app--feat-auth--a1b2c3.md"
cp "$FIXTURES/stale-session.md" "$HOME/.agent-sessions/old-project--dev--d4e5f6.md"

# Bump active session updated time to now (platform-specific)
now_iso="$(date "+%Y-%m-%dT%H:%M:%S")"
if sed --version >/dev/null 2>&1; then
  sed -i "s/^updated: .*/updated: ${now_iso}+00:00/" "$HOME/.agent-sessions/my-app--feat-auth--a1b2c3.md"
else
  sed -i '' "s/^updated: .*/updated: ${now_iso}+00:00/" "$HOME/.agent-sessions/my-app--feat-auth--a1b2c3.md"
fi

out="$(bash "$SCRIPT")"
echo "$out"

echo "$out" | grep -q "UPDATED" || fail "output missing header"
echo "$out" | grep -q "my-app" || fail "output missing active project"
echo "$out" | grep -q "old-project" || fail "output missing stale project"
echo "$out" | grep -q "active" || fail "output missing active status"
echo "$out" | grep -q "stale" || fail "output missing stale status"
echo "$out" | grep -q "2 session(s) total" || fail "output missing session count"
echo "$out" | grep -q "1 stale" || fail "output missing stale count"
pass "fixture dashboard output"

# --- Test 3: missing frontmatter fields still render ---
cat > "$HOME/.agent-sessions/minimal--no-branch--x9y8z7.md" <<EOF
---
project: minimal
updated: ${now_iso}+00:00
---

# Current Task

Minimal task line
EOF

out="$(bash "$SCRIPT")"
echo "$out" | grep -q "minimal" || fail "minimal fixture not listed"
pass "partial frontmatter handled"

echo
echo "All smoke tests passed."
