# Contributing to WIAWAI

Thanks for helping improve WIAWAI. This project ships one agent skill (`session-recall`) plus a CLI helper script.

## Development setup

```bash
npx skills add daskinnyman/WIAWAI --skill '*' -g
ln -s "$(pwd)/skills/session-recall" ~/.cursor/skills/session-recall
ln -s "$(pwd)/skills/wiawai-checkpoint" ~/.cursor/skills/wiawai-checkpoint
# ... wiawai-recall, wiawai-dashboard, wiawai-list
```

## Quality checks

Run before opening a PR:

```bash
chmod +x tests/*.sh skills/session-recall/scripts/list-sessions.sh
tests/validate-skill.sh
STRICT=1 tests/validate-skill.sh    # warnings fail too
tests/run-smoke-test.sh
shellcheck skills/session-recall/scripts/list-sessions.sh   # optional, if installed
```

CI runs the same checks on every push and pull request.

## Manual evaluation

Agent behavior cannot be fully tested in CI. See [evals/manual.md](evals/manual.md) for the pre-release checklist.

## Pull request guidelines

1. Keep `SKILL.md` skimmable — prefer short bullets over long prose
2. Never instruct agents to store secrets in status files
3. Update README.md and README.zh-TW.md if install paths or commands change
4. Add or update fixtures in `tests/fixtures/` if CLI output format changes
5. One logical change per PR when possible

## Project layout

```
skills/session-recall/   # Skill source (published via npx skills add)
tests/                   # Automated validation and smoke tests
evals/                   # Manual agent evaluation checklist
examples/                # Sample status file for documentation
apps/cli/                # CLI documentation
```
