# 🧭 WIAWAI

**我是誰，我在哪？** — 多開 terminal 也不忘每個 session 正在做什麼。

WIAWAI 是 **Who I Am, Where Am I** 的縮寫，中文即「我是誰，我在哪？」。它是一套跨 Agent 的 Session Recall skill，適用於 [Cursor](https://cursor.com)、[Claude Code](https://docs.anthropic.com/en/docs/claude-code)、Codex、Windsurf、Cline、Copilot 等支援 [Agent Skills](https://skills.sh) 的工具。每個 session 會在本地寫入一份簡短狀態檔；切換視窗或隔一段時間回來，問一句就能在幾秒內接上進度。

[English](README.md) · [简体中文](README.zh-CN.md)

[安裝](#-安裝) · [使用方式](#-使用方式) · [運作原理](#-運作原理) · [CLI](#-cli) · [隱私](#-隱私)

---

## 😵 問題

同時開好幾個 coding agent 很常見，但要記住「這個視窗剛剛在做什麼」卻很難。

你回到一小時前的 session，只能往上捲對話紀錄，試著拼出 branch、目標、已完成項目、下一步。每次 context switch 都要重來一次，摩擦會一直累積。

WIAWAI 為每個 session 保留一份十秒內能讀完的狀態筆記，讓你立刻回到工作節奏。

## ✨ 使用前 vs 使用後

| 沒有 WIAWAI | 有 WIAWAI |
|---|---|
| 📜 往上捲對話，試著重建 context | 💬 說 `recall` 或 `我在幹嘛`，取得結構化摘要 |
| 🤷 不確定這個 terminal 是哪個專案、哪個 branch | 📁 狀態檔記錄 project、branch、cwd |
| 🪟 無法一眼看見所有 session 在做什麼 | 📊 `/wiawai-dashboard` 顯示跨 session 看板 |
| 💭 context 只存在對話紀錄裡 | 💾 context 持久化在 `~/.agent-sessions/` |

`recall` 回應範例：

> **目標：** 在 `feat-auth` branch 實作 JWT refresh flow。  
> **已完成：** Refresh endpoint 與 token middleware。  
> **進行中：** Integration tests。  
> **下一步：** 處理 expired refresh token。

## 📦 安裝

```bash
npx skills add daskinnyman/WIAWAI --skill '*' -g
```

會安裝 `session-recall` 與所有 `/wiawai-*` 斜線指令 skill。若只要核心 skill：

```bash
npx skills add daskinnyman/WIAWAI@session-recall -g
```

Skill 安裝位置：

| 範圍 | Cursor | Codex、Cline 等大多數 agent |
|---|---|---|
| 專案（預設） | `.agents/skills/<skill-name>/` | `.agents/skills/<skill-name>/` |
| 全域（`-g`） | `~/.cursor/skills/<skill-name>/` | `~/.agents/skills/<skill-name>/` |

可加上 `-y` 略過確認提示。第一次 `/wiawai-checkpoint` 時會自動建立狀態目錄。

<details>
<summary>手動安裝</summary>

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

### Commands（斜線指令）

在 Agent 對話框輸入 `/` 直接呼叫：

| 指令 | 動作 |
|---|---|
| `/wiawai-checkpoint` | 💾 儲存或更新這個 session 的狀態檔 |
| `/wiawai-recall` | 📝 摘要這個 session：目標、進度、下一步 |
| `/wiawai-dashboard` | 📊 顯示這台機器上所有 session 的看板 |
| `/wiawai-list` | 📊 同 `/wiawai-dashboard` |

需先完成 [安裝](#-安裝)（含 `--skill '*'`）。

### 自然語言（選用）

核心 **`session-recall`** 僅在**唯讀**語句時 auto-invoke（如 `我在幹嘛`、`所有 session`），並**轉去執行對應的 `wiawai-*` skill**，本身不重複那些步驟。

**寫入**請用 **`/wiawai-checkpoint`** — 不會自動 checkpoint。

回應語言會跟隨你使用的語言。文件為英文；摘要可以是繁體中文或其他語言。

### 🕸️ 過期 session

超過三天未更新的 session 會標記為 **stale**（過期）。Agent 可在你同意後協助清理這些檔案。

## ⚙️ 運作原理

每個 session 寫入一個 markdown 檔：

```
~/.agent-sessions/<project>--<branch>--<short-id>.md
```

檔案包含 YAML frontmatter（`project`、`cwd`、`branch`、`agent`、時間戳）以及 Current Task、Done、In Progress、Next Steps、Decisions & Gotchas 等簡短區段。

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

不開 agent 也能直接執行看板腳本。請依安裝方式選對路徑：

| 安裝方式 | 指令 |
|---|---|
| `npx skills add`（專案範圍） | `bash .agents/skills/session-recall/scripts/list-sessions.sh` |
| `npx skills add -g`（Cursor） | `bash ~/.cursor/skills/session-recall/scripts/list-sessions.sh` |
| `npx skills add -g`（Codex / Cline 等） | `bash ~/.agents/skills/session-recall/scripts/list-sessions.sh` |
| clone 本 repo | `bash skills/session-recall/scripts/list-sessions.sh` |

輸出範例：

```
UPDATED     PROJECT         BRANCH      TASK              AGENT   STATUS
------------------------------------------------------------------------------------------
2m ago      my-app          feat-auth   Implement JWT refresh token...  cursor  active
1h ago      api-server      main        Fix rate limiter bug...         claude-code  active
5d ago      old-project     dev         Refactor DB layer...            cursor  stale

3 session(s) total, 1 stale (>3 days without update).
```

更多說明：[apps/cli/README.zh-TW.md](apps/cli/README.zh-TW.md) · [CLI 简体中文](apps/cli/README.zh-CN.md)

## 📂 專案結構

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

## ✅ 品質

[![Validate](https://github.com/daskinnyman/WIAWAI/actions/workflows/validate.yml/badge.svg)](https://github.com/daskinnyman/WIAWAI/actions/workflows/validate.yml)

每次發版前會執行：

- `tests/validate-skill.sh` — metadata、結構、token 估算
- `tests/run-smoke-test.sh` — 用 fixture 測 CLI 輸出
- `list-sessions.sh` 的 ShellCheck
- 手動驗收清單：[evals/manual.md](evals/manual.md)

貢獻指南：[CONTRIBUTING.md](CONTRIBUTING.md)

## 🔒 隱私

WIAWAI 不會將資料傳送到外部伺服器。沒有 telemetry、analytics 或帳號系統。狀態檔為本地 plain markdown。Skill 指示 agent 不得將 secret、API key 或 credentials 寫入狀態檔。

僅在安裝時（`npx skills add`）需要網路連線。

## 📄 授權

MIT
