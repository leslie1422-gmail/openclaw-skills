# github-collab-executor

Implements the GitHub Collaboration Protocol — automated task routing, status reporting, and handoff between two agents sharing a single GitHub token.

## When to Use

When a user asks to perform GitHub operations and the task falls under one of these categories:
- Scan repository status (issues, PRs, CI, commits)
- Generate a collaboration report or weekly summary
- Execute a predefined collaboration workflow (assign → act → report → handoff)

## How It Relates to github-collab.md

`github-collab.md` defines the **rules**. This skill **automates the execution** of those rules.

## Core Logic

### 1. Scan Phase
```bash
# List all repos
curl -s -H "Authorization: token $GH_TOKEN" \
  "https://api.github.com/user/repos?per_page=100&sort=updated"

# For each repo: check issues, PRs, CI status, last commit
```

### 2. Classify Phase
| Situation | Route To |
|-----------|----------|
| Issue: simple reply / label | → Execute (this agent) |
| Issue: complex / architecture | → @Hermes Agent |
| PR: no conflict + CI green | → Execute (this agent) |
| PR: complex review / CI failing | → @Hermes Agent |
| New file/edit ≤5 lines | → Execute (this agent) |
| New file/edit >5 lines or new feature | → @Hermes Agent |

### 3. Act Phase
Execute the action. Log to shared log file.

### 4. Report Phase
Post summary to the HermesClaw collaboration group:
```
[@target-agent]
Action: did X
Result: Y
Status: done / waiting for you / blocked
```

## Tools Used

| Tool | Purpose |
|------|---------|
| `exec` | Run GitHub API calls (curl) |
| `memory_search` | Load github-collab.md protocol |
| `message` | Post reports to collaboration group |

## Environment

Requires `GH_TOKEN` in the environment. If not set, reads from `~/.hermes/.env`.

## Output

JSON status report:
```json
{
  "status": "success",
  "phase": "scan|classify|act|report",
  "repos_scanned": 2,
  "issues_found": 0,
  "prs_found": 0,
  "actions_taken": [],
  "next_steps": "@Hermes if complex issues found"
}
```

## Cron Scheduling

Daily patrol (recommended):
```json
{
  "schedule": { "kind": "cron", "expr": "0 9 * * *", "tz": "Asia/Shanghai" },
  "payload": { "kind": "agentTurn", "message": "Run github-collab-executor daily patrol" }
}
```

## Author

Leslie & Hermes Agent

## Last Updated

2026-04-16
