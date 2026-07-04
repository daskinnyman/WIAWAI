---
name: session-recall
description: >
  WIAWAI reference skill — status file format, local storage rules, and natural-language
  entry points. Auto-invoke only for read-only recall ("what was I doing", "我在幹嘛") or
  dashboard requests ("what are my other sessions doing", "所有 session"). For writes use
  /wiawai-checkpoint. Executable steps live in wiawai-checkpoint, wiawai-recall,
  wiawai-dashboard, and wiawai-list skills.
author: daskinnyman
license: MIT
repository: https://github.com/daskinnyman/WIAWAI
keywords:
  - session
  - context
  - productivity
  - cursor
  - claude-code
---

# Session Recall (reference)

This skill is the **spec and router** for WIAWAI. It does not duplicate step-by-step instructions — those live in the slash-command skills below.

## Slash commands (preferred)

| Command | Skill | Action |
|---|---|---|
| `/wiawai-checkpoint` | `wiawai-checkpoint` | Save or update this session's status file |
| `/wiawai-recall` | `wiawai-recall` | Summarize this session |
| `/wiawai-dashboard` | `wiawai-dashboard` | Dashboard of all sessions |
| `/wiawai-list` | `wiawai-list` | Alias for dashboard |

Each slash skill has `disable-model-invocation: true`. **Follow that skill's SKILL.md exactly** when the user runs the matching `/` command.

## Natural language (this skill only)

When the user does **not** use `/`, this skill may auto-invoke for **read-only** requests only:

| User intent | Follow skill |
|---|---|
| "recall", "what was I doing", "what am I doing", "session status", "我在幹嘛", "我這個 session 在幹嘛" | **`wiawai-recall`** |
| "what are my other sessions doing", "所有 session" | **`wiawai-dashboard`** |

For **writes** (checkpoint, save session status, 存檔), do **not** auto-invoke. Tell the user to run **`/wiawai-checkpoint`**.

Do **not** treat generic phrases like "list sessions" or "show all sessions" as WIAWAI — suggest `/wiawai-dashboard`.

Do not invoke this skill for unrelated coding questions.

## State directory

```
~/.agent-sessions/
```

Create on first checkpoint. Local markdown only — never upload.

## Session file naming

```
<project>--<branch>--<short-id>.md
```

- **project**: git root basename, or cwd basename if not a git repo
- **branch**: current git branch, or `no-branch`
- **short-id**: first 6 hex chars, generated once per session

Example: `my-app--feat-auth--a3f9c2.md`

## Status file format

```markdown
---
project: my-app
cwd: /Users/dev/projects/my-app
branch: feat-auth
agent: cursor
created: 2026-07-04T10:00:00+08:00
updated: 2026-07-04T14:30:00+08:00
---

# Current Task

One-line summary

## Done

- 3-5 bullets max

## In Progress

- Active work

## Next Steps

- Immediate next actions

## Decisions & Gotchas

- Non-obvious items only
```

Entire file skimmable in under 10 seconds. Example: [examples/sample-status.md](../../examples/sample-status.md) in the WIAWAI repo.

## Dashboard script

`list-sessions.sh` lives in this skill's `scripts/` directory. The `wiawai-dashboard` skill runs it — paths by install scope:

| Agent / scope | Path |
|---|---|
| Cursor, global (`-g`) | `~/.cursor/skills/session-recall/scripts/list-sessions.sh` |
| Codex, Cline, etc., global | `~/.agents/skills/session-recall/scripts/list-sessions.sh` |
| Project scope | `.agents/skills/session-recall/scripts/list-sessions.sh` |

## Global rules

1. **Never** store secrets, API keys, or credentials in status files.
2. **Reads** may be automatic (via this skill); **writes** only via `/wiawai-checkpoint` or explicit user consent per `wiawai-checkpoint`.
3. Do not commit status files to git.
4. Set `agent` in frontmatter when known: `cursor`, `claude-code`, `codex`, `windsurf`, or `unknown`.
5. Sessions not updated in **>3 days** are **stale** — see `wiawai-dashboard` for listing and cleanup.
