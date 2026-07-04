# 🖥️ WIAWAI — CLI

用命令行查看 [WIAWAI](../../README.zh-CN.md) skill 写入的 session 状态文件。

[English](README.md) · [繁體中文](README.zh-TW.md)

## 概述

Skill 会为每个 agent session 在 `~/.agent-sessions/` 写入一个状态文件。CLI 脚本读取这些文件并输出排序后的看板，适合不想开 agent 却想快速总览所有 session 时使用。

## 使用方式

请依 skill 的安装方式选对路径：

| 安装方式 | 指令 |
|---|---|
| `npx skills add`（项目范围） | `bash .agents/skills/session-recall/scripts/list-sessions.sh` |
| `npx skills add -g`（Cursor） | `bash ~/.cursor/skills/session-recall/scripts/list-sessions.sh` |
| `npx skills add -g`（Codex / Cline 等） | `bash ~/.agents/skills/session-recall/scripts/list-sessions.sh` |
| clone 本 repo | `bash skills/session-recall/scripts/list-sessions.sh` |

### 输出示例

```
UPDATED     PROJECT         BRANCH      TASK              AGENT   STATUS
------------------------------------------------------------------------------------------
2m ago      my-app          feat-auth   Implement JWT refresh token...  cursor  active
1h ago      api-server      main        Fix rate limiter bug...         claude-code  active
5d ago      old-project     dev         Refactor DB layer...            cursor  stale

3 session(s) total, 1 stale (>3 days without update).
```

## 字段说明

| 字段 | 说明 |
|---|---|
| **UPDATED** | ⏱️ 状态文件最后更新距今多久 |
| **PROJECT** | 📁 Git repository 名称（非 git 目录则为文件夹名称） |
| **BRANCH** | 🌿 目前 git branch，或 `no-branch` |
| **TASK** | 📌 「Current Task」段落的第一行 |
| **AGENT** | 🤖 checkpoint 时记录的 agent 平台（如 `cursor`、`claude-code`） |
| **STATUS** | ✅ 三天内有更新为 `active`；⚠️ 超过三天为 `stale` |

## 状态文件位置

```
~/.agent-sessions/<project>--<branch>--<short-id>.md
```

文件由 agent 在你运行 `/wiawai-checkpoint` 时创建或更新。完整格式见 [SKILL.md](../../skills/session-recall/SKILL.md)。

## Agent 指令

CLI 脚本只负责列出 session。若要透过 agent 写入或读取状态，请使用：

| 指令 | 动作 |
|---|---|
| `/wiawai-checkpoint` | 💾 创建或更新目前 session 的状态文件 |
| `/wiawai-recall` | 📝 取得目前 session 的简短摘要 |
| `/wiawai-dashboard` · `/wiawai-list` | 📊 请 agent 执行看板脚本 |

## 需求

- Bash（macOS、Linux、WSL）
- `~/.agent-sessions/` 内已有状态文件（skill 第一次 checkpoint 时创建）

## 故障排除

**找不到任何 session**

请先在至少一个 agent session 中运行 `/wiawai-checkpoint`。

**project 或 branch 名称不正确**

状态文件的 project 取自 git root 名称，branch 取自 `git branch`。非 git 目录会使用文件夹名称与 `no-branch`。

**安装后找不到脚本**

依 agent 与安装范围检查路径：

```bash
# Cursor，全局
ls ~/.cursor/skills/session-recall/scripts/list-sessions.sh

# Codex / Cline 等，全局
ls ~/.agents/skills/session-recall/scripts/list-sessions.sh

# 项目范围
ls .agents/skills/session-recall/scripts/list-sessions.sh
```

必要时重新安装：

```bash
npx skills add daskinnyman/WIAWAI@session-recall -g
```

加上 `-y` 可跳过确认提示。不加 `-g` 则只安装在目前项目。

## 相关链接

- [主 README（简体中文）](../../README.zh-CN.md)
- [主 README（繁體中文）](../../README.zh-TW.md)
- [Main README (English)](../../README.md)
- [Skill 源代码](../../skills/session-recall/SKILL.md)
