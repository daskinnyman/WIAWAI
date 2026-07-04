---
name: session-recall
description: >
  Track and recall what each coding session is working on across multiple terminals.
  Use when the user says "checkpoint", "recall", "what was I doing", "session status",
  "what am I doing", "我在幹嘛", "list sessions", "show all sessions", "what are my
  other sessions doing", or when resuming work after a context switch. Maintains status
  files in ~/.agent-sessions/ and provides a cross-session dashboard.
---

# Session Recall

Help the user remember what each coding session is doing. Persist lightweight status files to a shared directory so any session can recall its own context or list all active sessions.

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

**Triggers:** user says "checkpoint", or after completing a significant milestone (feature done, bug fixed, major refactor, plan approved).

**On first use in a session:**

1. Determine `project`, `cwd`, `branch`, and generate a `short-id`.
2. Create the session file at `~/.agent-sessions/<project>--<branch>--<short-id>.md`.
3. Remember this file path for the rest of the session.

**On every checkpoint:**

1. Read the existing file (if any).
2. Update frontmatter `updated` to current ISO 8601 timestamp.
3. Rewrite body sections from current conversation context:
   - **Current Task**: one line
   - **Done**: 3-5 bullets max
   - **In Progress**: what is actively being worked on
   - **Next Steps**: immediate next actions
   - **Decisions & Gotchas**: only non-obvious items
4. Write the file. Confirm briefly: "Checkpoint saved."

Do not checkpoint on every message — only on explicit request or meaningful progress.

### 2. Recall (read, current session)

**Triggers:** "recall", "what was I doing", "what am I doing", "session status", "我在幹嘛", "我這個 session 在幹嘛", or when the user seems lost about current work.

**Steps:**

1. Locate this session's status file (use remembered path, or find the most recently updated file matching current `project` + `branch`).
2. Read the file and scan recent conversation.
3. Respond in **5-8 lines** covering:
   - **Goal**: what this session is trying to accomplish
   - **Done**: key completed items
   - **In progress**: what is active right now
   - **Next step**: the single most immediate action

**Output language:** match the user's language (English, 繁體中文, etc.).

If no status file exists, summarize from conversation context and offer to create a checkpoint.

### 3. Dashboard (read, all sessions)

**Triggers:** "list sessions", "show all sessions", "what are my other sessions doing", "session dashboard", "所有 session".

**Steps:**

1. Run the helper script:

```bash
bash ~/.agents/skills/session-recall/scripts/list-sessions.sh
```

If the skill is installed elsewhere, resolve the script path relative to this SKILL.md location.

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
3. On session start (first user message about recall/checkpoint), auto-create a checkpoint if none exists for this session.
4. Status files are user-local state — do not commit them to git repos.

## Example Interactions

**User:** checkpoint

**Agent:** *(writes/updates status file)* Checkpoint saved. Current task: implement JWT refresh flow. Next: integration tests.

---

**User:** what was I doing?

**Agent:**
> **Goal:** Implement JWT refresh token flow for my-app (feat-auth branch).
> **Done:** Refresh endpoint added, middleware updated.
> **In progress:** Integration tests for refresh flow.
> **Next step:** Add error handling for expired refresh tokens.

---

**User:** show all sessions

**Agent:** *(runs list-sessions.sh)*

| Updated | Project | Branch | Task | Status |
|---------|---------|--------|------|--------|
| 2m ago | my-app | feat-auth | JWT refresh flow | active |
| 1h ago | api-server | main | Fix rate limiter bug | active |
| 5d ago | old-project | dev | Refactor DB layer | stale |

Two stale sessions found. Delete them?
