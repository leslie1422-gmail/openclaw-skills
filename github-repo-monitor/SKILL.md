# github-repo-monitor

Monitor GitHub repos for CI failures, new issues, and stale PRs

## When to Use

When a user asks to perform tasks related to: **Monitor GitHub repos for CI failures, new issues, and stale PRs**

## Core Logic

1. Receive user request with context
2. Validate required parameters
3. Execute primary action using: exec,read,write
4. Format and return results
5. Handle errors gracefully with fallback

## Tools Used

| Tool | Purpose |
|------|---------|
| `exec` | Exec |
| `read` | Read |
| `write` | Write |

## Output

Returns a structured result with:
- **status**: success / error
- **message**: human-readable summary
- **data**: raw output (if applicable)

## Error Handling

- If primary tool fails → try fallback method
- If all tools fail → return error with clear reason
- Log errors for later review

## Cron Scheduling (Optional)

```json
{
  "schedule": { "kind": "cron", "expr": "0 9 * * *", "tz": "Asia/Shanghai" },
  "payload": { "kind": "agentTurn", "message": "Run github-repo-monitor" }
}
```

## Author

Leslie & Hermes

## Last Updated

2026-04-16
