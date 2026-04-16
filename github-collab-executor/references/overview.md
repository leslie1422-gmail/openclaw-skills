# github-collab-executor — Design Overview

## Purpose

Execute the GitHub Collaboration Protocol defined in `github-collab.md` automatically. Two agents (小龙虾 + Hermes) share one GitHub token and need automated coordination.

## How It Works

```
scan_repos()
  ↓
for each repo: scan_repo_details()
  ↓
classify() → determine action
  ↓
act() OR escalate to @Hermes
  ↓
generate_report() → post to collaboration group
```

## Key Design Decisions

1. **Bash over Python** — Available everywhere, no extra dependencies, works in all environments both agents run in.
2. **JSON report files** — Both agents can read/write shared reports via filesystem.
3. **No locking mechanism** — Agents coordinate via message passing in the collaboration group. Token conflicts are resolved by "notify before acting" rule.
4. **API over gh CLI** — `curl` + GitHub REST API works identically on both agents' environments.

## Task Routing Logic

| Task Type | Agent |
|-----------|-------|
| Simple issue reply | 小龙虾 |
| Add labels | 小龙虾 |
| Close duplicate issues | 小龙虾 |
| PR review (trivial) | 小龙虾 |
| Merge (no conflict, CI green) | 小龙虾 |
| README typo fix | 小龙虾 |
| Architecture-level issue | Hermes |
| Complex PR review | Hermes |
| New feature implementation | Hermes |
| CI/CD pipeline design | Hermes |
| Release planning | Hermes |

## Shared Log Locations

- Patrol log: `~/.openclaw/logs/github-collab-executor.log`
- JSON report: `~/.openclaw/logs/github-collab-report.json`
- Protocol: `~/.hermes/skills/github-collab.md`

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-04-16 | Initial executor implementation |
