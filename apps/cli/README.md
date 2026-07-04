# 🖥️ WIAWAI — CLI

Command-line helper for viewing session status files written by the [WIAWAI](../../README.md) skill.

[繁體中文](README.zh-TW.md) · [简体中文](README.zh-CN.md)

## Overview

The skill stores one status file per agent session in `~/.agent-sessions/`. The CLI script reads those files and prints a sorted dashboard — useful when you want a quick overview without opening an agent session.

## Usage

Use the path that matches how you installed the skill:

| Install method | Command |
|---|---|
| `npx skills add` (project scope) | `bash .agents/skills/session-recall/scripts/list-sessions.sh` |
| `npx skills add -g` on Cursor | `bash ~/.cursor/skills/session-recall/scripts/list-sessions.sh` |
| `npx skills add -g` on Codex / Cline / etc. | `bash ~/.agents/skills/session-recall/scripts/list-sessions.sh` |
| Cloned this repo | `bash skills/session-recall/scripts/list-sessions.sh` |

### Example output

```
UPDATED     PROJECT         BRANCH      TASK              AGENT   STATUS
------------------------------------------------------------------------------------------
2m ago      my-app          feat-auth   Implement JWT refresh token...  cursor  active
1h ago      api-server      main        Fix rate limiter bug...         claude-code  active
5d ago      old-project     dev         Refactor DB layer...            cursor  stale

3 session(s) total, 1 stale (>3 days without update).
```

## Columns

| Column | Description |
|---|---|
| **UPDATED** | ⏱️ Time since the status file was last modified |
| **PROJECT** | 📁 Git repository name (or directory name if not in a repo) |
| **BRANCH** | 🌿 Current git branch, or `no-branch` |
| **TASK** | 📌 First line under the "Current Task" section |
| **AGENT** | 🤖 Agent platform recorded at checkpoint (e.g. `cursor`, `claude-code`) |
| **STATUS** | ✅ `active` if updated within 3 days; ⚠️ `stale` otherwise |

## Status file location

```
~/.agent-sessions/<project>--<branch>--<short-id>.md
```

Files are created and updated by the agent when you say `checkpoint`, or automatically after significant progress. See [SKILL.md](../../skills/session-recall/SKILL.md) for the full format.

## Agent commands

The CLI script only lists sessions. To write or read status through an agent, use:

| Command | Action |
|---|---|
| `/wiawai-checkpoint` | 💾 Create or update the current session's status file |
| `/wiawai-recall` | 📝 Get a brief summary of the current session |
| `/wiawai-dashboard` · `/wiawai-list` | 📊 Ask the agent to run the dashboard script |

## Requirements

- Bash (macOS, Linux, WSL)
- Status files in `~/.agent-sessions/` (created by the skill on first checkpoint)

## Troubleshooting

**No sessions found**

Run `checkpoint` in at least one agent session first.

**Wrong project or branch name**

Status files derive the project name from the git root and the branch from `git branch`. Directories outside a git repository use the folder name and `no-branch`.

**Script not found after install**

Check the path for your agent and install scope:

```bash
# Cursor, global
ls ~/.cursor/skills/session-recall/scripts/list-sessions.sh

# Codex / Cline / etc., global
ls ~/.agents/skills/session-recall/scripts/list-sessions.sh

# Project scope
ls .agents/skills/session-recall/scripts/list-sessions.sh
```

Reinstall if needed:

```bash
npx skills add daskinnyman/WIAWAI@session-recall -g
```

Add `-y` to skip confirmation prompts. Omit `-g` to install only in the current project.

## Related

- [Main README (English)](../../README.md)
- [主 README（繁體中文）](../../README.zh-TW.md)
- [主 README（简体中文）](../../README.zh-CN.md)
- [Skill source](../../skills/session-recall/SKILL.md)
