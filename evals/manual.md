# Manual Evaluation Checklist

Use this checklist before publishing a new version of WIAWAI `session-recall`. Run automated checks first (`tests/validate-skill.sh`, `tests/run-smoke-test.sh`), then verify agent behavior manually in at least two agents (e.g. Cursor + Claude Code).

## Install

- [ ] `npx skills add daskinnyman/WIAWAI@session-recall` installs without errors
- [ ] `npx skills add daskinnyman/WIAWAI@session-recall -g` installs to the correct global path for your agent
- [ ] Manual symlink install works (see README)

## Checkpoint

- [ ] `/wiawai-checkpoint` creates `~/.agent-sessions/<project>--<branch>--<id>.md`
- [ ] Status file has frontmatter: `project`, `cwd`, `branch`, `agent`, `created`, `updated`
- [ ] Body sections present: Current Task, Done, In Progress, Next Steps
- [ ] Entire file readable in under 10 seconds
- [ ] Second `checkpoint` updates `updated` timestamp without creating a duplicate file
- [ ] Agent does not write API keys, tokens, or credentials into the status file

## Recall

- [ ] `/wiawai-recall` — returns goal, done, in progress, next step in 5–8 lines
- [ ] Natural language `我在幹嘛` also works when core skill auto-invokes
- [ ] Recall with no prior checkpoint still summarizes from conversation and offers to checkpoint

## Dashboard

- [ ] `/wiawai-dashboard` — agent runs `list-sessions.sh` and shows a table
- [ ] Table sorted by most recently updated first
- [ ] Sessions older than 3 days marked `stale`
- [ ] Agent offers to delete stale files when stale sessions exist
- [ ] CLI works directly: `bash skills/session-recall/scripts/list-sessions.sh` (from repo clone)

## Cross-session

- [ ] Open two terminals on different projects; checkpoint both
- [ ] `/wiawai-dashboard` shows both entries with correct project/branch names
- [ ] Switch back to terminal A; `/wiawai-recall` matches terminal A's work (not terminal B)

## Edge cases

- [ ] Non-git directory uses folder name and `no-branch`
- [ ] Long task titles truncate gracefully in CLI output
- [ ] Empty `~/.agent-sessions/` reports "No sessions found" without crashing

## Sign-off

| Field | Value |
|---|---|
| Version / commit | |
| Agent tested | |
| OS | |
| Tester | |
| Date | |
| Pass / Fail | |
