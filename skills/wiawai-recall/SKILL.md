---
name: wiawai-recall
description: Summarize what this coding session is working on from WIAWAI status files. Use when the user runs /wiawai-recall.
disable-model-invocation: true
author: daskinnyman
license: MIT
repository: https://github.com/daskinnyman/WIAWAI
---

# /wiawai-recall

Recall what **this session** is doing.

## Steps

1. Find this session's status file in `~/.agent-sessions/` (match current `project` + `branch`, or the most recent file for this session).
2. Read the file and scan recent conversation.
3. Reply in **5–8 lines**: **Goal**, **Done**, **In progress**, **Next step**.

Match the user's language (English, 繁體中文, etc.).

If no status file exists, summarize from conversation only. Offer `/wiawai-checkpoint` to save a local status note — do not write unless the user runs that command or confirms.
