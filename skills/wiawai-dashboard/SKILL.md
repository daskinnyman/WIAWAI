---
name: wiawai-dashboard
description: Show a dashboard of all WIAWAI agent sessions on this machine. Use when the user runs /wiawai-dashboard.
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

If not in the skill directory, use the installed `session-recall` skill path:

| Agent / scope | Path |
|---|---|
| Cursor, global (`-g`) | `~/.cursor/skills/session-recall/scripts/list-sessions.sh` |
| Codex, Cline, etc., global | `~/.agents/skills/session-recall/scripts/list-sessions.sh` |
| Project scope | `.agents/skills/session-recall/scripts/list-sessions.sh` |

2. Present the output as a table sorted by last updated.
3. Flag sessions older than 3 days as **stale** and offer cleanup.

Also accept `/wiawai-list` as an alias for this command.
