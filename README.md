# Session Recall

**Remember what each terminal is working on — without re-reading scrollback.**

Session Recall is a cross-agent skill for [Cursor](https://cursor.com), [Claude Code](https://docs.anthropic.com/en/docs/claude-code), Codex, Windsurf, Cline, Copilot, and other agents that support [Agent Skills](https://skills.sh). Each session writes a short status file to a shared local folder. When you switch tabs or come back later, ask what you were doing and get a concise answer in seconds.

[Install](#install) · [Usage](#usage) · [How it works](#how-it-works) · [CLI](#cli) · [Privacy](#privacy)

---

## The problem

Running multiple coding agents across terminals is common. Remembering which window was on which task is not.

You open a session you left an hour ago and scroll through output trying to reconstruct context: the branch, the goal, what's done, what's next. That friction adds up on every switch.

Session Recall keeps a lightweight status note per session — readable in under ten seconds — so you can resume work immediately.

## Before and after

| Without Session Recall | With Session Recall |
|---|---|
| Scroll through agent output to reconstruct context | Ask `recall` and get a structured summary |
| Unsure which project or branch this terminal belongs to | Status file records project, branch, and cwd |
| No overview across open sessions | `list sessions` shows all sessions on one dashboard |
| Context lives only in chat history | Context persists on disk in `~/.agent-sessions/` |

Example recall response:

> **Goal:** Implement JWT refresh flow on branch `feat-auth`.  
> **Done:** Refresh endpoint and token middleware.  
> **In progress:** Integration tests.  
> **Next:** Handle expired refresh tokens.

## Install

```bash
npx skills add daskinnyman/HIMWAI@session-recall -g -y
```

No account required. The status directory is created automatically on the first checkpoint.

<details>
<summary>Manual install</summary>

```bash
git clone https://github.com/daskinnyman/HIMWAI.git
ln -s "$(pwd)/skills/session-recall" ~/.agents/skills/session-recall
```

</details>

## Usage

Talk to your agent in plain language:

| Trigger | Action |
|---|---|
| `checkpoint` | Save or update this session's status file |
| `recall` · `what was I doing` · `我在幹嘛` | Summarize this session: goal, progress, next step |
| `list sessions` · `show all sessions` | Show a dashboard of all sessions on this machine |

The agent also checkpoints automatically after meaningful progress. Saying `checkpoint` before switching away is recommended.

Response language follows the language you use. Documentation is in English; summaries can be in 繁體中文 or any other language.

### Stale sessions

Sessions without updates for more than three days are marked **stale**. The agent can offer to remove stale files on request.

## How it works

Each session writes one markdown file:

```
~/.agent-sessions/<project>--<branch>--<short-id>.md
```

The file contains YAML frontmatter (`project`, `cwd`, `branch`, `agent`, timestamps) and short sections for the current task, completed work, in-progress items, next steps, and key decisions.

```
Terminal A                         Terminal B
     │                                  │
     ▼                                  ▼
checkpoint                          checkpoint
     │                                  │
     └────────► ~/.agent-sessions/ ◄────┘
                        │
              list-sessions.sh
                        │
            cross-session dashboard
```

## CLI

Run the dashboard script directly, without an agent:

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

More detail: [apps/cli/README.md](apps/cli/README.md)

## Project structure

```
skills/session-recall/
  SKILL.md                  # Agent instructions
  scripts/list-sessions.sh  # Session dashboard script
```

## Privacy

Session Recall does not send data to external servers. There is no telemetry, analytics, or account system. Status files are plain markdown stored locally. The skill instructs agents not to write secrets, API keys, or credentials into status files.

Network access is only required during installation (`npx skills add`).

## License

MIT
