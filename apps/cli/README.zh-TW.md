# 🖥️ WIAWAI — CLI

用命令列查看 [WIAWAI](../../README.zh-TW.md) skill 寫入的 session 狀態檔。

🇺🇸 [English](README.md)

## 概述

Skill 會為每個 agent session 在 `~/.agent-sessions/` 寫入一個狀態檔。CLI 腳本讀取這些檔案並輸出排序後的看板，適合不想開 agent 卻想快速總覽所有 session 時使用。

## 使用方式

請依 skill 的安裝方式選對路徑：

| 安裝方式 | 指令 |
|---|---|
| `npx skills add`（專案範圍） | `bash .agents/skills/session-recall/scripts/list-sessions.sh` |
| `npx skills add -g`（Cursor） | `bash ~/.cursor/skills/session-recall/scripts/list-sessions.sh` |
| `npx skills add -g`（Codex / Cline 等） | `bash ~/.agents/skills/session-recall/scripts/list-sessions.sh` |
| clone 本 repo | `bash skills/session-recall/scripts/list-sessions.sh` |

### 輸出範例

```
UPDATED     PROJECT         BRANCH      TASK              AGENT   STATUS
------------------------------------------------------------------------------------------
2m ago      my-app          feat-auth   Implement JWT refresh token...  cursor  active
1h ago      api-server      main        Fix rate limiter bug...         claude-code  active
5d ago      old-project     dev         Refactor DB layer...            cursor  stale

3 session(s) total, 1 stale (>3 days without update).
```

## 欄位說明

| 欄位 | 說明 |
|---|---|
| **UPDATED** | ⏱️ 狀態檔最後更新距今多久 |
| **PROJECT** | 📁 Git repository 名稱（非 git 目錄則為資料夾名稱） |
| **BRANCH** | 🌿 目前 git branch，或 `no-branch` |
| **TASK** | 📌 「Current Task」區段的第一行 |
| **AGENT** | 🤖 checkpoint 時記錄的 agent 平台（如 `cursor`、`claude-code`） |
| **STATUS** | ✅ 三天內有更新為 `active`；⚠️ 超過三天為 `stale` |

## 狀態檔位置

```
~/.agent-sessions/<project>--<branch>--<short-id>.md
```

檔案由 agent 在你說 `checkpoint` 時建立或更新，或在有意義的進度完成後自動更新。完整格式見 [SKILL.md](../../skills/session-recall/SKILL.md)。

## Agent 指令

CLI 腳本只負責列出 session。若要透過 agent 寫入或讀取狀態，請使用：

| 指令 | 動作 |
|---|---|
| `/wiawai-checkpoint` | 💾 建立或更新目前 session 的狀態檔 |
| `/wiawai-recall` | 📝 取得目前 session 的簡短摘要 |
| `/wiawai-dashboard` · `/wiawai-list` | 📊 請 agent 執行看板腳本 |

## 需求

- Bash（macOS、Linux、WSL）
- `~/.agent-sessions/` 內已有狀態檔（skill 第一次 checkpoint 時建立）

## 故障排除

**找不到任何 session**

請先在至少一個 agent session 中執行 `checkpoint`。

**project 或 branch 名稱不正確**

狀態檔的 project 取自 git root 名稱，branch 取自 `git branch`。非 git 目錄會使用資料夾名稱與 `no-branch`。

**安裝後找不到腳本**

依 agent 與安裝範圍檢查路徑：

```bash
# Cursor，全域
ls ~/.cursor/skills/session-recall/scripts/list-sessions.sh

# Codex / Cline 等，全域
ls ~/.agents/skills/session-recall/scripts/list-sessions.sh

# 專案範圍
ls .agents/skills/session-recall/scripts/list-sessions.sh
```

必要時重新安裝：

```bash
npx skills add daskinnyman/WIAWAI@session-recall -g
```

加上 `-y` 可略過確認提示。不加 `-g` 則只安裝在目前專案。

## 相關連結

- [主 README（中文）](../../README.zh-TW.md)
- [Main README (English)](../../README.md)
- [Skill 原始碼](../../skills/session-recall/SKILL.md)
