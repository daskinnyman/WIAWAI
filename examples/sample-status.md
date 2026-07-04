---
project: my-app
cwd: /Users/dev/projects/my-app
branch: feat-auth
agent: cursor
created: 2026-07-04T10:00:00+08:00
updated: 2026-07-04T14:30:00+08:00
---

# Current Task

Implement JWT refresh token flow

## Done

- Added refresh endpoint in auth router
- Updated token expiry middleware

## In Progress

- Writing integration tests for refresh flow

## Next Steps

- Add error handling for expired refresh tokens
- Update API docs

## Decisions & Gotchas

- Using 7-day refresh token TTL (not 30) per security review
- Must invalidate old refresh token on rotation
