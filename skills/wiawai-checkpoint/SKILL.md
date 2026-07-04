---
name: wiawai-checkpoint
description: Save or update this coding session's WIAWAI status file in ~/.agent-sessions/. Use when the user runs /wiawai-checkpoint.
disable-model-invocation: true
author: daskinnyman
license: MIT
repository: https://github.com/daskinnyman/WIAWAI
---

# /wiawai-checkpoint

Save this session's status to `~/.agent-sessions/<project>--<branch>--<short-id>.md` (local markdown only; nothing is uploaded).

## Steps

1. Determine `project` (git root basename or cwd basename), `cwd`, `branch` (or `no-branch`), and reuse or create a `short-id`.
2. If no status file exists yet for this session, `/wiawai-checkpoint` counts as user consent — proceed without an extra confirmation prompt.
3. Write or update the status file with YAML frontmatter and sections: **Current Task**, **Done**, **In Progress**, **Next Steps**, **Decisions & Gotchas**.
4. Set `updated` to the current ISO 8601 timestamp.
5. Reply with the full path, e.g. "Updated local status file `~/.agent-sessions/my-app--feat-auth--a3f9c2.md` (local only)." plus one-line task and next step.

Keep the file skimmable in under 10 seconds. Never store secrets, API keys, or credentials.

Full format and rules: see `session-recall` skill in the same WIAWAI package.
