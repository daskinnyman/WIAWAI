#!/usr/bin/env bash
# validate-skill.sh — Check all WIAWAI skills under skills/.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_ROOT="$ROOT/skills"

errors=0
warnings=0

fail() { echo "  [error]   $1"; errors=$((errors + 1)); }
warn() { echo "  [warning] $1"; warnings=$((warnings + 1)); }
pass() { echo "  [pass]    $1"; }

validate_one_skill() {
  local skill_dir="$1"
  local skill_name
  skill_name="$(basename "$skill_dir")"
  local skill_md="$skill_dir/SKILL.md"

  echo "=== $skill_name ==="

  [[ -f "$skill_md" ]] || { fail "Missing $skill_md"; echo; return; }

  local frontmatter
  frontmatter="$(awk '/^---$/{c++; next} c==1{print} c==2{exit}' "$skill_md")"

  get_field() {
    local field="$1"
    echo "$frontmatter" | awk -v f="$field" '$0 ~ "^" f ": " || $0 ~ "^" f ":$" { sub("^" f ": ?", ""); print; exit }'
  }

  get_description() {
    awk '
      /^description: >$/ { fold=1; next }
      fold && /^  / { gsub(/^  /, ""); desc = desc $0 " "; next }
      /^description: / { sub(/^description: /, ""); print; exit }
      END { if (desc != "") { gsub(/ +$/, "", desc); print desc } }
    ' <<< "$frontmatter"
  }

  local name description license repository author
  name="$(get_field name)"
  description="$(get_description)"
  license="$(get_field license)"
  repository="$(get_field repository)"
  author="$(get_field author)"

  if [[ -z "$name" ]]; then
    fail "frontmatter: name is required"
  elif [[ "$name" != "$skill_name" ]]; then
    fail "frontmatter: name must match folder ($skill_name, got: $name)"
  else
    pass "name: $name"
  fi

  if [[ -z "$description" ]]; then
    fail "frontmatter: description is required"
  elif [[ ${#description} -lt 20 ]]; then
    fail "frontmatter: description too short (${#description} chars)"
  else
    pass "description: ${#description} chars"
  fi

  [[ -n "$license" ]] && pass "license: $license" || warn "frontmatter: license missing"
  [[ -n "$repository" ]] && pass "repository: set" || warn "frontmatter: repository missing"
  [[ -n "$author" ]] && pass "author: $author" || warn "frontmatter: author missing"

  if [[ "$skill_name" == "session-recall" ]]; then
    [[ -x "$skill_dir/scripts/list-sessions.sh" ]] || fail "Missing scripts/list-sessions.sh"
    [[ -f "$ROOT/examples/sample-status.md" ]] || warn "Missing examples/sample-status.md"
  fi

  if grep -q "disable-model-invocation: true" "$skill_md"; then
    pass "slash command skill (disable-model-invocation)"
  fi

  echo
}

echo "Validating WIAWAI skills..."
echo

for skill_dir in "$SKILLS_ROOT"/*/; do
  [[ -f "${skill_dir}SKILL.md" ]] || continue
  validate_one_skill "${skill_dir%/}"
done

echo "Results: $errors error(s), $warnings warning(s)"
if [[ $errors -gt 0 ]]; then
  exit 1
fi

if [[ "${STRICT:-}" == "1" ]] && [[ $warnings -gt 0 ]]; then
  exit 1
fi

exit 0
