# Session Recall

A cross-agent skill that helps you remember what each coding session is working on when you juggle multiple terminals and context switches.

## Problem

When running several coding agents in different terminals, it is easy to forget what a given session was doing. Session Recall keeps a lightweight status file per session in a shared directory so you can recall context instantly.

## Install

After publishing to GitHub:

```bash
npx skills add <owner>/HIAWAI@session-recall -g -y
```

Or install manually:

```bash
git clone https://github.com/<owner>/HIAWAI.git
ln -s "$(pwd)/skills/session-recall" ~/.agents/skills/session-recall
```

## Usage

In any coding agent session:

| Command | What it does |
|---------|--------------|
| `checkpoint` | Save current session status to `~/.agent-sessions/` |
| `recall` / `what was I doing` / `我在幹嘛` | Brief summary of this session |
| `list sessions` / `show all sessions` | Dashboard of all active sessions |

The agent auto-checkpoints after significant milestones. Status files stay skimmable in under 10 seconds.

## How it works

```
Terminal A (project-foo)          Terminal B (project-bar)
        |                                  |
        v                                  v
   checkpoint                         checkpoint
        |                                  |
        +----------> ~/.agent-sessions/ <--+
                         |
                    list-sessions.sh
                         |
                   cross-session dashboard
```

Each session writes a markdown file:

```
~/.agent-sessions/<project>--<branch>--<short-id>.md
```

## Files

```
skills/session-recall/
  SKILL.md                  # Agent instructions
  scripts/list-sessions.sh  # Dashboard helper
```

## License

MIT
