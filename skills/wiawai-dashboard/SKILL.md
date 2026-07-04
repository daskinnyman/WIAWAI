---
name: wiawai-dashboard
description: Show a dashboard of all WIAWAI agent sessions on this machine. Use when the user runs /wiawai-dashboard, or when session-recall routes a cross-session read request here.
disable-model-invocation: true
author: daskinnyman
license: MIT
repository: https://github.com/daskinnyman/WIAWAI
---

# /wiawai-dashboard

List all sessions tracked in `~/.agent-sessions/`.

## Steps

1. Run the dashboard script. Try paths in order until one works:

```bash
bash scripts/list-sessions.sh
```

If not in the skill directory, use the `session-recall` skill install path:

| Agent / scope | Path |
|---|---|
| Cursor, global (`-g`) | `~/.cursor/skills/session-recall/scripts/list-sessions.sh` |
| Codex, Cline, etc., global | `~/.agents/skills/session-recall/scripts/list-sessions.sh` |
| Project scope | `.agents/skills/session-recall/scripts/list-sessions.sh` |

2. Present the output as a table sorted by last updated (script handles sorting).
3. Flag sessions with `updated` older than **3 days** as **stale**.
4. If stale sessions exist, ask: "Delete stale session files?" On confirmation, remove only files older than 3 days from `~/.agent-sessions/`.

Do **not** respond to generic "list sessions" / "show all sessions" unless the user clearly means WIAWAI — suggest `/wiawai-dashboard` instead.

Also accept `/wiawai-list` as an alias (same steps).
