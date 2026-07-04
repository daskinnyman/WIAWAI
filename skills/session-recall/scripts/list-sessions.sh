#!/usr/bin/env bash
# list-sessions.sh — Print a dashboard of all agent session status files.
set -euo pipefail

SESSION_DIR="${HOME}/.agent-sessions"
STALE_DAYS=3

if [[ ! -d "$SESSION_DIR" ]]; then
  echo "No sessions found. Directory does not exist: $SESSION_DIR"
  exit 0
fi

shopt -s nullglob
files=("$SESSION_DIR"/*.md)

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No sessions found in $SESSION_DIR"
  exit 0
fi

# Parse a frontmatter field from a markdown file
get_field() {
  local file="$1" field="$2"
  awk -v f="$field" '
    /^---$/ { fm=1; next }
    fm && /^---$/ { exit }
    fm && $0 ~ "^" f ": " { sub("^" f ": ", ""); print; exit }
  ' "$file"
}

# Human-readable relative time from ISO 8601 timestamp
time_ago() {
  local ts="$1"
  local now epoch then diff

  # macOS and Linux compatible epoch conversion
  if date -j -f "%Y-%m-%dT%H:%M:%S" "${ts:0:19}" "+%s" &>/dev/null; then
    epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${ts:0:19}" "+%s" 2>/dev/null || echo 0)
  else
    epoch=$(date -d "${ts:0:19}" "+%s" 2>/dev/null || echo 0)
  fi
  now=$(date "+%s")
  then=$epoch
  diff=$(( now - then ))

  if [[ $diff -lt 60 ]]; then
    echo "${diff}s ago"
  elif [[ $diff -lt 3600 ]]; then
    echo "$(( diff / 60 ))m ago"
  elif [[ $diff -lt 86400 ]]; then
    echo "$(( diff / 3600 ))h ago"
  else
    echo "$(( diff / 86400 ))d ago"
  fi
}

# Extract first line under "# Current Task" heading
get_task() {
  local file="$1"
  awk '
    /^# Current Task/ { found=1; next }
    found && /^#/ { exit }
    found && NF { print; exit }
  ' "$file" | head -1
}

# Collect session data into temp file for sorting
tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

for f in "${files[@]}"; do
  updated=$(get_field "$f" "updated")
  project=$(get_field "$f" "project")
  branch=$(get_field "$f" "branch")
  task=$(get_task "$f")
  agent=$(get_field "$f" "agent")

  [[ -z "$updated" ]] && updated="1970-01-01T00:00:00"
  [[ -z "$project" ]] && project="unknown"
  [[ -z "$branch" ]] && branch="unknown"
  [[ -z "$task" ]] && task="(no task set)"
  [[ -z "$agent" ]] && agent="?"

  # Determine staleness
  if date -j -f "%Y-%m-%dT%H:%M:%S" "${updated:0:19}" "+%s" &>/dev/null; then
    epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${updated:0:19}" "+%s" 2>/dev/null || echo 0)
  else
    epoch=$(date -d "${updated:0:19}" "+%s" 2>/dev/null || echo 0)
  fi
  now=$(date "+%s")
  age_days=$(( (now - epoch) / 86400 ))
  if [[ $age_days -gt $STALE_DAYS ]]; then
    status="stale"
  else
    status="active"
  fi

  ago=$(time_ago "$updated")
  # Sort key: updated timestamp (descending), tab-separated fields
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$updated" "$ago" "$project" "$branch" "$task" "$agent" "$status" >> "$tmpfile"
done

# Print header
printf "%-10s  %-14s  %-10s  %-16s  %-6s  %s\n" "UPDATED" "PROJECT" "BRANCH" "TASK" "AGENT" "STATUS"
printf '%.0s-' {1..90}
echo ""

# Sort by updated descending, print table
sort -t$'\t' -k1 -r "$tmpfile" | while IFS=$'\t' read -r _updated ago project branch task agent status; do
  # Truncate long task strings
  if [[ ${#task} -gt 30 ]]; then
    task="${task:0:27}..."
  fi
  printf "%-10s  %-14s  %-10s  %-16s  %-6s  %s\n" "$ago" "$project" "$branch" "$task" "$agent" "$status"
done

# Count stale
stale_count=$(grep -c $'\tstale$' "$tmpfile" 2>/dev/null || echo 0)
total=${#files[@]}
echo ""
echo "$total session(s) total, $stale_count stale (>${STALE_DAYS} days without update)."
