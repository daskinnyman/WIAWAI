# 🧭 WIAWAI

**我是誰，我在哪？** — 多開 terminal 也不忘每個 session 正在做什麼。

WIAWAI 是 **Who I Am, Where Am I** 的縮寫，中文即「我是誰，我在哪？」。它是一套跨 Agent 的 Session Recall skill，適用於 [Cursor](https://cursor.com)、[Claude Code](https://docs.anthropic.com/en/docs/claude-code)、Codex、Windsurf、Cline、Copilot 等支援 [Agent Skills](https://skills.sh) 的工具。每個 session 會在本地寫入一份簡短狀態檔；切換視窗或隔一段時間回來，問一句就能在幾秒內接上進度。

🇺🇸 [English README](README.md)

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
| 🪟 無法一眼看見所有 session 在做什麼 | 📊 `list sessions` 顯示跨 session 看板 |
| 💭 context 只存在對話紀錄裡 | 💾 context 持久化在 `~/.agent-sessions/` |

`recall` 回應範例：

> **目標：** 在 `feat-auth` branch 實作 JWT refresh flow。  
> **已完成：** Refresh endpoint 與 token middleware。  
> **進行中：** Integration tests。  
> **下一步：** 處理 expired refresh token。

## 📦 安裝

```bash
npx skills add daskinnyman/WIAWAI@session-recall
```

不需要帳號。第一次 `checkpoint` 時會自動建立狀態目錄。

可選參數：

| 參數 | 作用 |
|---|---|
| `-g` | 全域安裝（`~/.agents/skills/`），所有專案都能用 |
| `-y` | 略過確認提示，適合腳本或 agent 自動執行 |

個人使用、跨專案都需要的話，建議加上 `-g`：

```bash
npx skills add daskinnyman/WIAWAI@session-recall -g
```

<details>
<summary>手動安裝</summary>

```bash
git clone https://github.com/daskinnyman/WIAWAI.git
ln -s "$(pwd)/skills/session-recall" ~/.agents/skills/session-recall
```

</details>

## 🗣️ 使用方式

用自然語言跟 agent 說即可：

| 觸發語 | 動作 |
|---|---|
| `checkpoint` | 💾 儲存或更新這個 session 的狀態檔 |
| `recall` · `what was I doing` · `我在幹嘛` | 📝 摘要這個 session：目標、進度、下一步 |
| `list sessions` · `show all sessions` | 📊 顯示這台機器上所有 session 的看板 |

Agent 在有意義的進度完成後也會自動 checkpoint。建議在切換視窗前手動說一次 `checkpoint`。

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

不開 agent 也能直接執行看板腳本：

```bash
bash ~/.agents/skills/session-recall/scripts/list-sessions.sh
```

輸出範例：

```
UPDATED     PROJECT         BRANCH      TASK              AGENT   STATUS
------------------------------------------------------------------------------------------
2m ago      my-app          feat-auth   Implement JWT refresh token...  cursor  active
1h ago      api-server      main        Fix rate limiter bug...         claude-code  active
5d ago      old-project     dev         Refactor DB layer...            cursor  stale

3 session(s) total, 1 stale (>3 days without update).
```

更多說明：[apps/cli/README.zh-TW.md](apps/cli/README.zh-TW.md)

## 📂 專案結構

```
WIAWAI/
  skills/session-recall/
    SKILL.md                  # Agent 指令
    scripts/list-sessions.sh  # Session 看板腳本
  apps/cli/                   # CLI 文件
```

## 🔒 隱私

WIAWAI 不會將資料傳送到外部伺服器。沒有 telemetry、analytics 或帳號系統。狀態檔為本地 plain markdown。Skill 指示 agent 不得將 secret、API key 或 credentials 寫入狀態檔。

僅在安裝時（`npx skills add`）需要網路連線。

## 📄 授權

MIT
