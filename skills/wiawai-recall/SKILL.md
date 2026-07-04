---
name: wiawai-recall
description: Summarize what this coding session is working on from WIAWAI status files. Use when the user runs /wiawai-recall, or when session-recall routes a natural-language recall request here.
disable-model-invocation: true
author: daskinnyman
license: MIT
repository: https://github.com/daskinnyman/WIAWAI
---

# /wiawai-recall

Recall what **this session** is doing.

## Steps

1. Locate this session's status file in `~/.agent-sessions/` (use remembered path, or match current `project` + `branch`, or the most recent file for this session).
2. Read the file and scan recent conversation.
3. Reply in **5–8 lines**:
   - **Goal**: what this session is trying to accomplish
   - **Done**: key completed items
   - **In progress**: what is active right now
   - **Next step**: the single most immediate action

**Output language:** match the user's language (English, 繁體中文, etc.).

If no status file exists, summarize from conversation only. Offer `/wiawai-checkpoint` — do not write a file unless the user runs that command or confirms.

Status file format: see `session-recall` skill in the same WIAWAI package.
