<div align="center">

# Session Recall CLI

**Three terminals. Three agents. Zero idea which one was fixing the auth bug.**

Stop context-switch amnesia. One shared folder on disk. Every session writes a 10-second status note. You ask *"what was I doing?"* — answer in five lines.

<br />

[![Install](https://img.shields.io/badge/install-npx%20skills%20add-000?style=for-the-badge)](https://github.com/daskinnyman/HIMWAI)
[![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)](#license)

[See it](#before--after) ·
[Install](#install) ·
[Commands](#commands) ·
[How it works](#how-it-works) ·
[Privacy](#privacy)

</div>

---

Session Recall is a cross-agent skill for [Cursor](https://cursor.com), [Claude Code](https://docs.anthropic.com/en/docs/claude-code), Codex, Windsurf, Cline, Copilot, and 30+ other agents that support [Agent Skills](https://skills.sh). Each terminal keeps a tiny markdown status file in `~/.agent-sessions/`. Switch windows, come back hours later, still know exactly where you left off.

## Before / After

<table>
<tr>
<td width="50%">

**Without Session Recall**

> *Opens Terminal 2. Stares at agent output.*
>
> "Wait… was this the JWT branch or the rate-limiter fix? Did I already write the tests? Which repo is this even?"

Five minutes lost. Every switch. Every day.

</td>
<td width="50%">

**With Session Recall**

> **Goal:** JWT refresh flow on `feat-auth`.
> **Done:** Endpoint + middleware.
> **In progress:** Integration tests.
> **Next:** Expired-token error handling.

Five lines. Ten seconds. Back in flow.

</td>
</tr>
</table>

```
┌──────────────────────────────────────────────┐
│  time to recall context    ████░░░░░░   ~10s │
│  sessions tracked          unlimited       │
│  network calls             zero            │
│  secrets in status files   never           │
└──────────────────────────────────────────────┘
```

Session Recall does not make the agent smarter. It makes **you** remember what you were already doing.

## Install

**One command. Works with any agent on the skills registry.**

```bash
npx skills add daskinnyman/HIMWAI@session-recall -g -y
```

~10 seconds. No accounts. No config file. Status files land in `~/.agent-sessions/` automatically on first checkpoint.

> [!TIP]
> **Try it now:** open any agent session and say **`checkpoint`**, then **`recall`**. Or in Chinese: **`我在幹嘛`**.

<details>
<summary><strong>Manual install, or symlink for development</strong></summary>

```bash
git clone https://github.com/daskinnyman/HIMWAI.git
ln -s "$(pwd)/skills/session-recall" ~/.agents/skills/session-recall
```

Re-run safe. Uninstall by removing the symlink and deleting `~/.agent-sessions/` if you want a clean slate.

</details>

## Commands

Talk to your agent in plain language. The skill handles the rest.

| Say this | What happens |
|---|---|
| `checkpoint` | Write or update this session's status file |
| `recall` · `what was I doing` · `我在幹嘛` | 5–8 line brief: goal, done, in progress, next step |
| `list sessions` · `show all sessions` | Dashboard of every terminal/session on this machine |

**CLI script** (runs standalone, no agent needed):

```bash
bash ~/.agents/skills/session-recall/scripts/list-sessions.sh
```

Example output:

```
UPDATED     PROJECT         BRANCH      TASK              AGENT   STATUS
------------------------------------------------------------------------------------------
2m ago      my-app          feat-auth   Implement JWT refresh token...  cursor  active
1h ago      api-server      main        Fix rate limiter bug...         claude-code  active
5d ago      old-project     dev         Refactor DB layer...            cursor  stale

3 session(s) total, 1 stale (>3 days without update).
```

> [!NOTE]
> **Output language follows you.** Skill docs are English; summaries match whatever language you type in.

## Pick your moment

Three behaviors. One idea: **never lose the thread.**

| Mode | When to use | Trigger |
|---|---|---|
| **Checkpoint** | After a milestone, before you switch away | `checkpoint` |
| **Recall** | You just came back and forgot | `recall` · `我在幹嘛` |
| **Dashboard** | You want the map of all sessions | `list sessions` |

Sessions untouched for **>3 days** show as **stale**. Agent offers to clean them up. Your call.

## How it works

```
 Terminal A (my-app)              Terminal B (api-server)
         │                                   │
         ▼                                   ▼
    checkpoint                            checkpoint
         │                                   │
         └──────────► ~/.agent-sessions/ ◄──┘
                              │
                    list-sessions.sh
                              │
                   cross-session dashboard
```

Each session writes one file:

```
~/.agent-sessions/<project>--<branch>--<short-id>.md
```

Frontmatter holds metadata (`project`, `cwd`, `branch`, `agent`, timestamps). Body holds four skimmable sections: **Current Task**, **Done**, **In Progress**, **Next Steps**, plus **Decisions & Gotchas** for the non-obvious stuff.

The agent auto-checkpoints after meaningful progress. You never have to babysit it — but saying `checkpoint` before you Alt-Tab away is the move.

## What you get

| Piece | Location | Role |
|---|---|---|
| Skill instructions | `skills/session-recall/SKILL.md` | Tells every agent how to checkpoint, recall, and dashboard |
| Dashboard script | `skills/session-recall/scripts/list-sessions.sh` | Fast table of all sessions, sorted by last update |
| Status files | `~/.agent-sessions/*.md` | Your local session memory — one file per agent session |

## Privacy

Session Recall does not phone home. No telemetry, no analytics, no accounts, no backend. Status files are plain markdown on your disk. The skill never stores API keys, tokens, or credentials — if the agent tries, the skill rules say no.

Install-time network: only `npx skills add` fetching from GitHub/skills.sh. After that, zero network.

## Stale sessions & cleanup

| Status | Meaning |
|---|---|
| `active` | Updated within the last 3 days |
| `stale` | No update in 3+ days — probably abandoned |

Ask your agent to delete stale files, or remove them yourself:

```bash
rm ~/.agent-sessions/*--old-branch--*.md
```

## Troubleshooting

**"No sessions found"**

Run `checkpoint` in at least one agent session first. The directory is created on first write.

**Dashboard shows wrong project name**

Status files key off git root basename + branch. Non-git folders use cwd basename and `no-branch`.

**Agent doesn't activate the skill**

Confirm install: `ls ~/.agents/skills/session-recall/SKILL.md`. Then say `recall` or `checkpoint` explicitly.

---

<div align="center">

**Star this repo if it saved you from opening the wrong terminal again.** ⭐

[Report an issue](https://github.com/daskinnyman/HIMWAI/issues) ·
[Main README](../../README.md) ·
[Skill source](../../skills/session-recall/SKILL.md)

MIT — free like open tabs on a Friday afternoon.

</div>
