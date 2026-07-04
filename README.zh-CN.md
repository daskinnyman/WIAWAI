# 🧭 WIAWAI

**我是谁，我在哪？** — 多开 terminal 也不忘每个 session 正在做什么。

WIAWAI 是 **Who I Am, Where Am I** 的缩写，中文即「我是谁，我在哪？」。它是一套跨 Agent 的 Session Recall skill，适用于 [Cursor](https://cursor.com)、[Claude Code](https://docs.anthropic.com/en/docs/claude-code)、Codex、Windsurf、Cline、Copilot 等支持 [Agent Skills](https://skills.sh) 的工具。每个 session 会在本地写入一份简短状态文件；切换窗口或隔一段时间回来，问一句就能在几秒内接上进度。

[English](README.md) · [繁體中文](README.zh-TW.md)

[安装](#-安装) · [使用方式](#-使用方式) · [运作原理](#-运作原理) · [CLI](#-cli) · [隐私](#-隐私)

---

## 😵 问题

同时开好几个 coding agent 很常见，但要记住「这个窗口刚刚在做什么」却很难。

你回到一小时前的 session，只能往上滚对话记录，试着拼出 branch、目标、已完成项目、下一步。每次 context switch 都要重来一次，摩擦会一直累积。

WIAWAI 为每个 session 保留一份十秒内能读完的状态笔记，让你立刻回到工作节奏。

## ✨ 使用前 vs 使用后

| 没有 WIAWAI | 有 WIAWAI |
|---|---|
| 📜 往上滚对话，试着重建 context | 💬 运行 `/wiawai-recall` 或说「我在干嘛」，取得结构化摘要 |
| 🤷 不确定这个 terminal 是哪个项目、哪个 branch | 📁 状态文件记录 project、branch、cwd |
| 🪟 无法一眼看见所有 session 在做什么 | 📊 `/wiawai-dashboard` 显示跨 session 看板 |
| 💭 context 只存在对话记录里 | 💾 context 持久化在 `~/.agent-sessions/` |

`/wiawai-recall` 响应示例：

> **目标：** 在 `feat-auth` branch 实现 JWT refresh flow。  
> **已完成：** Refresh endpoint 与 token middleware。  
> **进行中：** Integration tests。  
> **下一步：** 处理 expired refresh token。

## 📦 安装

```bash
npx skills add daskinnyman/WIAWAI --skill '*' -g
```

会安装 `session-recall` 与所有 `/wiawai-*` 斜线指令 skill。若只要核心 skill：

```bash
npx skills add daskinnyman/WIAWAI@session-recall -g
```

Skill 安装位置：

| 范围 | Cursor | Codex、Cline 等大多数 agent |
|---|---|---|
| 项目（默认） | `.agents/skills/<skill-name>/` | `.agents/skills/<skill-name>/` |
| 全局（`-g`） | `~/.cursor/skills/<skill-name>/` | `~/.agents/skills/<skill-name>/` |

可加上 `-y` 跳过确认提示。第一次 `/wiawai-checkpoint` 时会自动创建状态目录。

<details>
<summary>手动安装</summary>

```bash
git clone https://github.com/daskinnyman/WIAWAI.git
cd WIAWAI

for skill in session-recall wiawai-checkpoint wiawai-recall wiawai-dashboard wiawai-list; do
  ln -sf "$(pwd)/skills/$skill" ~/.cursor/skills/$skill
  ln -sf "$(pwd)/skills/$skill" ~/.agents/skills/$skill
done
```

</details>

## 🗣️ 使用方式

### Commands（斜线指令）

在 Agent 对话框输入 `/` 直接调用：

| 指令 | 动作 |
|---|---|
| `/wiawai-checkpoint` | 💾 保存或更新这个 session 的状态文件 |
| `/wiawai-recall` | 📝 摘要这个 session：目标、进度、下一步 |
| `/wiawai-dashboard` | 📊 显示这台机器上所有 session 的看板 |
| `/wiawai-list` | 📊 同 `/wiawai-dashboard` |

需先完成 [安装](#-安装)（含 `--skill '*'`）。

### 自然语言（选用）

核心 **`session-recall`** 仅在**只读**语句时 auto-invoke（如 `我在干嘛`、`所有 session`），并**转去执行对应的 `wiawai-*` skill**，本身不重复那些步骤。

**写入**请用 **`/wiawai-checkpoint`** — 不会自动 checkpoint。

响应语言会跟随你使用的语言。文档为英文；摘要可以是简体中文、繁體中文或其他语言。

### 🕸️ 过期 session

超过三天未更新的 session 会标记为 **stale**（过期）。Agent 可在你同意后协助清理这些文件。

## ⚙️ 运作原理

每个 session 写入一个 markdown 文件：

```
~/.agent-sessions/<project>--<branch>--<short-id>.md
```

文件包含 YAML frontmatter（`project`、`cwd`、`branch`、`agent`、时间戳）以及 Current Task、Done、In Progress、Next Steps、Decisions & Gotchas 等简短段落。

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
              跨 session 看板
```

## 🖥️ CLI

不开 agent 也能直接执行看板脚本。请依安装方式选对路径：

| 安装方式 | 指令 |
|---|---|
| `npx skills add`（项目范围） | `bash .agents/skills/session-recall/scripts/list-sessions.sh` |
| `npx skills add -g`（Cursor） | `bash ~/.cursor/skills/session-recall/scripts/list-sessions.sh` |
| `npx skills add -g`（Codex / Cline 等） | `bash ~/.agents/skills/session-recall/scripts/list-sessions.sh` |
| clone 本 repo | `bash skills/session-recall/scripts/list-sessions.sh` |

输出示例：

```
UPDATED     PROJECT         BRANCH      TASK              AGENT   STATUS
------------------------------------------------------------------------------------------
2m ago      my-app          feat-auth   Implement JWT refresh token...  cursor  active
1h ago      api-server      main        Fix rate limiter bug...         claude-code  active
5d ago      old-project     dev         Refactor DB layer...            cursor  stale

3 session(s) total, 1 stale (>3 days without update).
```

更多说明：[apps/cli/README.zh-CN.md](apps/cli/README.zh-CN.md)

## 📂 项目结构

```
WIAWAI/
  skills/
    session-recall/
    wiawai-checkpoint/
    wiawai-recall/
    wiawai-dashboard/
    wiawai-list/
  tests/
  evals/manual.md
  examples/
  apps/cli/
```

## ✅ 质量

[![Validate](https://github.com/daskinnyman/WIAWAI/actions/workflows/validate.yml/badge.svg)](https://github.com/daskinnyman/WIAWAI/actions/workflows/validate.yml)

每次发版前会执行：

- `tests/validate-skill.sh` — metadata、结构、token 估算
- `tests/run-smoke-test.sh` — 用 fixture 测 CLI 输出
- `list-sessions.sh` 的 ShellCheck
- 手动验收清单：[evals/manual.md](evals/manual.md)

贡献指南：[CONTRIBUTING.md](CONTRIBUTING.md)

## 🔒 隐私

WIAWAI 不会将数据传送到外部服务器。没有 telemetry、analytics 或账号系统。状态文件为本地 plain markdown。Skill 指示 agent 不得将 secret、API key 或 credentials 写入状态文件。

仅在安装时（`npx skills add`）需要网络连接。

## 📄 授权

MIT
