---
name: wiawai-checkpoint
description: Save or update this coding session's WIAWAI status file in ~/.agent-sessions/. Use when the user runs /wiawai-checkpoint or explicitly asks to save session status.
disable-model-invocation: true
author: daskinnyman
license: MIT
repository: https://github.com/daskinnyman/WIAWAI
---

# /wiawai-checkpoint

Save this session's status to `~/.agent-sessions/<project>--<branch>--<short-id>.md` (local markdown only; nothing is uploaded).

## Steps

1. Determine `project` (git root basename or cwd basename), `cwd`, `branch` (or `no-branch`), and reuse or create a `short-id`.
2. **First write in this session** (no status file yet):
   - Unless the user ran `/wiawai-checkpoint` or clearly said "checkpoint" / "save session status" / "存檔", ask once: "Create local status file at `~/.agent-sessions/...`? (stored on your machine only)"
   - `/wiawai-checkpoint` or explicit checkpoint phrasing counts as consent — proceed without extra prompt.
3. Write or update the file with YAML frontmatter and sections: **Current Task**, **Done**, **In Progress**, **Next Steps**, **Decisions & Gotchas**.
4. Set `updated` to current ISO 8601 timestamp. Set `created` on first write.
5. Reply with the full path, e.g. "Updated local status file `~/.agent-sessions/my-app--feat-auth--a3f9c2.md` (local only)." plus one-line task and next step.

Keep the file skimmable in under 10 seconds. Never store secrets, API keys, or credentials.

File naming and format: see `session-recall` skill in the same WIAWAI package.
