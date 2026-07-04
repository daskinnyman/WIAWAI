---
name: session-recall
description: >
  Track and recall what each coding session is working on across multiple terminals.
  Slash commands: /wiawai-checkpoint, /wiawai-recall, /wiawai-dashboard, /wiawai-list.
  Auto-invoke only for explicit read-only recall ("what was I doing", "what am I doing",
  "session status", "我在幹嘛") or dashboard requests ("what are my other sessions doing",
  "所有 session"). Never auto-invoke checkpoint or any write to ~/.agent-sessions/.
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

# Session Recall

Help the user remember what each coding session is doing. Persist lightweight status files to a shared directory so any session can recall its own context or list all active sessions.

## Slash commands

Users invoke WIAWAI with `/` commands (install the matching skills from this repo):

| Command | Behavior |
|---|---|
| `/wiawai-checkpoint` | Save or update this session's status file |
| `/wiawai-recall` | Summarize this session |
| `/wiawai-dashboard` | Dashboard of all sessions on this machine |
| `/wiawai-list` | Alias for `/wiawai-dashboard` |

Each command is a separate skill with `disable-model-invocation: true` so it only runs when explicitly invoked.

## State Directory

All session status files live in:

```
~/.agent-sessions/
```

Create this directory if it does not exist.

## Session File Naming

```
<project>--<branch>--<short-id>.md
```

- **project**: basename of git root, or cwd basename if not a git repo
- **branch**: current git branch, or `no-branch`
- **short-id**: first 6 chars of a random hex string (generate once per session, reuse for the life of that session)

Example: `my-app--feat-auth--a3f9c2.md`

## Status File Format

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

Implement JWT refresh token flow

## Done

- Added refresh endpoint in auth router
- Updated token expiry middleware

## In Progress

- Writing integration tests for refresh flow

## Next Steps

- Add error handling for expired refresh tokens
- Update API docs

## Decisions & Gotchas

- Using 7-day refresh token TTL (not 30) per security review
- Must invalidate old refresh token on rotation
```

Keep every section terse. The entire file must be skimmable in under 10 seconds.

## Three Behaviors

### 1. Checkpoint (write)

**Triggers (explicit only):** user runs `/wiawai-checkpoint`, or clearly asks to save session status (e.g. "checkpoint", "save session status", "存檔").

**Never trigger checkpoint when:**
- The user asks a normal coding question
- The user only wants recall or a dashboard
- You finished a task but the user did not ask to save status

**On first write in a session (no status file yet):**

1. Tell the user what will happen: a local markdown note will be created at `~/.agent-sessions/<project>--<branch>--<short-id>.md` (local only, no upload).
2. Ask once: "Create this local status file?" / "要建立這個本地狀態檔嗎？"
3. Write only after the user confirms, or when they explicitly invoked `/wiawai-checkpoint` or said "checkpoint" (that counts as consent).
4. Determine `project`, `cwd`, `branch`, generate a `short-id`, and remember the file path for the rest of the session.

**On every checkpoint:**

1. Read the existing file (if any).
2. Update frontmatter `updated` to current ISO 8601 timestamp.
3. Rewrite body sections from current conversation context:
   - **Current Task**: one line
   - **Done**: 3-5 bullets max
   - **In Progress**: what is actively being worked on
   - **Next Steps**: immediate next actions
   - **Decisions & Gotchas**: only non-obvious items
4. Write the file. Confirm with the full path, e.g. "Updated local status file `~/.agent-sessions/my-app--feat-auth--a3f9c2.md` (local only). Current task: … Next: …"

Do not checkpoint on every message — only on explicit request.

### 2. Recall (read, current session)

**Triggers:** `/wiawai-recall`, or explicit natural language: "recall", "what was I doing", "what am I doing", "session status", "我在幹嘛", "我這個 session 在幹嘛".

**Steps:**

1. Locate this session's status file (use remembered path, or find the most recently updated file matching current `project` + `branch`).
2. Read the file and scan recent conversation.
3. Respond in **5-8 lines** covering:
   - **Goal**: what this session is trying to accomplish
   - **Done**: key completed items
   - **In progress**: what is active right now
   - **Next step**: the single most immediate action

**Output language:** match the user's language (English, 繁體中文, etc.).

If no status file exists, summarize from conversation context only. Offer `/wiawai-checkpoint` — do not create a file unless the user agrees.

### 3. Dashboard (read, all sessions)

**Triggers:** `/wiawai-dashboard`, `/wiawai-list`, or "what are my other sessions doing", "所有 session".

Do **not** use generic phrases like "list sessions" or "show all sessions" — they collide with other tools. Point users to `/wiawai-dashboard`.

**Steps:**

1. Run the helper script from the directory that contains this skill's `SKILL.md`:

```bash
bash scripts/list-sessions.sh
```

If that fails, try the installed path for your agent:

| Agent / scope | Path |
|---|---|
| Cursor, global (`-g`) | `~/.cursor/skills/session-recall/scripts/list-sessions.sh` |
| Codex, Cline, etc., global | `~/.agents/skills/session-recall/scripts/list-sessions.sh` |
| Project scope (default) | `.agents/skills/session-recall/scripts/list-sessions.sh` |

2. Present the output as a table sorted by last updated (script handles this).
3. Flag sessions with `updated` older than 3 days as **stale**.
4. Offer to delete stale session files if the user wants cleanup.

## Staleness & Cleanup

- Sessions not updated in **>3 days** are stale.
- When listing stale sessions, ask: "Delete stale session files?"
- On confirmation, remove only files older than 3 days from `~/.agent-sessions/`.

## Agent Field

Set `agent` in frontmatter to the platform name when known: `cursor`, `claude-code`, `codex`, `windsurf`, or `unknown`.

## Important Rules

1. **Never** store secrets, API keys, or credentials in status files.
2. Keep files small — if a section exceeds 5 bullets, trim to the most important items.
3. **Reads may be automatic; writes must always be explicit.** Never write or update a status file without the user requesting a checkpoint or confirming the first-time prompt.
4. Status files are user-local state — do not commit them to git repos.
5. Do not invoke this skill for unrelated questions. Answering a normal question is not a recall or checkpoint request.

## Example Interactions

**User:** /wiawai-checkpoint *(first time, no status file yet)*

**Agent:** *(writes file)* Updated local status file `~/.agent-sessions/my-app--feat-auth--a3f9c2.md` (local only). Current task: implement JWT refresh flow. Next: integration tests.

---

**User:** save session status *(first time, no status file yet)*

**Agent:** I can create a local status note at `~/.agent-sessions/my-app--feat-auth--<id>.md` (stored on your machine only). Create it?

**User:** yes

**Agent:** *(writes file)* Updated local status file `~/.agent-sessions/my-app--feat-auth--a3f9c2.md` (local only). …

---

**User:** /wiawai-recall

**Agent:**
> **Goal:** Implement JWT refresh token flow for my-app (feat-auth branch).
> **Done:** Refresh endpoint added, middleware updated.
> **In progress:** Integration tests for refresh flow.
> **Next step:** Add error handling for expired refresh tokens.

---

**User:** /wiawai-dashboard

**Agent:** *(runs list-sessions.sh)*

| Updated | Project | Branch | Task | Status |
|---------|---------|--------|------|--------|
| 2m ago | my-app | feat-auth | JWT refresh flow | active |
| 1h ago | api-server | main | Fix rate limiter bug | active |
| 5d ago | old-project | dev | Refactor DB layer | stale |

Two stale sessions found. Delete them?
