# 🧭 WIAWAI

**Who I Am, Where Am I** — remember what each terminal is working on, without re-reading scrollback.

**WIAWAI** (pronounced *why-uh-why*) stands for **Who I Am, Where Am I**. It is a cross-agent Session Recall skill for [Cursor](https://cursor.com), [Claude Code](https://docs.anthropic.com/en/docs/claude-code), Codex, Windsurf, Cline, Copilot, and other tools that support [Agent Skills](https://skills.sh). Each session writes a short local status file so you can resume in seconds after switching tabs or coming back later.

🇹🇼 [繁體中文說明](README.zh-TW.md)

[Install](#-install) · [Usage](#-usage) · [How it works](#-how-it-works) · [CLI](#-cli) · [Privacy](#-privacy)

---

## 😵 The problem

Running multiple coding agents across terminals is common. Remembering which window was on which task is not.

You open a session you left an hour ago and scroll through output trying to reconstruct context: the branch, the goal, what's done, what's next. That friction adds up on every switch.

WIAWAI keeps a lightweight status note per session — readable in under ten seconds — so you can resume work immediately.

## ✨ Before and after

| Without WIAWAI | With WIAWAI |
|---|---|
| 📜 Scroll through agent output to reconstruct context | 💬 Run `/wiawai-recall` and get a structured summary |
| 🤷 Unsure which project or branch this terminal belongs to | 📁 Status file records project, branch, and cwd |
| 🪟 No overview across open sessions | 📊 `/wiawai-dashboard` shows all sessions on one dashboard |
| 💭 Context lives only in chat history | 💾 Context persists on disk in `~/.agent-sessions/` |

Example recall response:

> **Goal:** Implement JWT refresh flow on branch `feat-auth`.  
> **Done:** Refresh endpoint and token middleware.  
> **In progress:** Integration tests.  
> **Next:** Handle expired refresh tokens.

## 📦 Install

```bash
npx skills add daskinnyman/WIAWAI --skill '*' -g
```

Installs `session-recall` plus all `/wiawai-*` slash-command skills. Omit `--skill '*'` to install only the core skill:

```bash
npx skills add daskinnyman/WIAWAI@session-recall -g
```

Where the skill is installed:

| Scope | Cursor | Codex, Cline, and most other agents |
|---|---|---|
| Project (default) | `.agents/skills/<skill-name>/` | `.agents/skills/<skill-name>/` |
| Global (`-g`) | `~/.cursor/skills/<skill-name>/` | `~/.agents/skills/<skill-name>/` |

Optional: add `-y` to skip confirmation prompts. The status directory is created automatically on the first `/wiawai-checkpoint`.

<details>
<summary>Manual install</summary>

```bash
git clone https://github.com/daskinnyman/WIAWAI.git
cd WIAWAI

for skill in session-recall wiawai-checkpoint wiawai-recall wiawai-dashboard wiawai-list; do
  ln -sf "$(pwd)/skills/$skill" ~/.cursor/skills/$skill
  ln -sf "$(pwd)/skills/$skill" ~/.agents/skills/$skill
done
```

</details>

## 🗣️ Usage

### Commands

Type `/` in Agent chat to invoke WIAWAI directly:

| Command | Action |
|---|---|
| `/wiawai-checkpoint` | 💾 Save or update this session's status file |
| `/wiawai-recall` | 📝 Summarize this session: goal, progress, next step |
| `/wiawai-dashboard` | 📊 Show a dashboard of all sessions on this machine |
| `/wiawai-list` | 📊 Alias for `/wiawai-dashboard` |

Requires the matching slash-command skills from the [install](#-install) step (`--skill '*'`).

### Natural language (optional)

The core **`session-recall`** skill auto-invokes only for **read-only** phrases (e.g. `我在幹嘛`, "what are my other sessions doing") and then **follows the matching `wiawai-*` skill** — it does not duplicate those steps.

For **writes**, use **`/wiawai-checkpoint`** — checkpoint is never auto-triggered.

Response language follows the language you use. Documentation is in English; summaries can be in 繁體中文 or any other language.

### 🕸️ Stale sessions

Sessions without updates for more than three days are marked **stale**. The agent can offer to remove stale files on request.

## ⚙️ How it works

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

## 🖥️ CLI

Run the dashboard script directly, without an agent. Use the path that matches how you installed:

| Install method | Command |
|---|---|
| `npx skills add` (project scope) | `bash .agents/skills/session-recall/scripts/list-sessions.sh` |
| `npx skills add -g` on Cursor | `bash ~/.cursor/skills/session-recall/scripts/list-sessions.sh` |
| `npx skills add -g` on Codex / Cline / etc. | `bash ~/.agents/skills/session-recall/scripts/list-sessions.sh` |
| Cloned this repo | `bash skills/session-recall/scripts/list-sessions.sh` |

Example output:

```
UPDATED     PROJECT         BRANCH      TASK              AGENT   STATUS
------------------------------------------------------------------------------------------
2m ago      my-app          feat-auth   Implement JWT refresh token...  cursor  active
1h ago      api-server      main        Fix rate limiter bug...         claude-code  active
5d ago      old-project     dev         Refactor DB layer...            cursor  stale

3 session(s) total, 1 stale (>3 days without update).
```

More detail: [apps/cli/README.md](apps/cli/README.md) · [CLI 中文說明](apps/cli/README.zh-TW.md)

## 📂 Project structure

```
WIAWAI/
  skills/
    session-recall/           # Spec, router, scripts (natural-language read only)
    wiawai-checkpoint/        # /wiawai-checkpoint — executable steps
    wiawai-recall/            # /wiawai-recall — executable steps
    wiawai-dashboard/         # /wiawai-dashboard — executable steps
    wiawai-list/              # /wiawai-list — alias
    session-recall/scripts/list-sessions.sh
  tests/
  evals/manual.md
  examples/
  apps/cli/
```

## ✅ Quality

[![Validate](https://github.com/daskinnyman/WIAWAI/actions/workflows/validate.yml/badge.svg)](https://github.com/daskinnyman/WIAWAI/actions/workflows/validate.yml)

Before each release we run:

- `tests/validate-skill.sh` — metadata, structure, token estimate
- `tests/run-smoke-test.sh` — CLI output with fixtures
- ShellCheck on `list-sessions.sh`
- Manual checklist in [evals/manual.md](evals/manual.md)

Contributing: [CONTRIBUTING.md](CONTRIBUTING.md)

## 🔒 Privacy

WIAWAI does not send data to external servers. There is no telemetry, analytics, or account system. Status files are plain markdown stored locally. The skill instructs agents not to write secrets, API keys, or credentials into status files.

Network access is only required during installation (`npx skills add`).

## 📄 License

MIT
