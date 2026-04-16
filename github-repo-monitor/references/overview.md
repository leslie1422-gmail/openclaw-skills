# github-repo-monitor — Design Overview

## Purpose

This skill is used for: Monitor GitHub repos for CI failures, new issues, and stale PRs

## Architecture

- **Entry**: `scripts/main.sh` — called by OpenClaw cron or agent
- **Spec**: `SKILL.md` — defines behavior for LLM consumption
- **Refs**: `references/` — human-readable design notes

## Design Decisions

1. **Why bash over Python?** — bash is available everywhere with no extra dependencies
2. **Why JSON output?** — OpenClaw agents parse JSON natively
3. **Why log file?** — enables debugging and audit trail

## Extending

To add new capabilities:
1. Edit `scripts/main.sh` — add new functions
2. Update `SKILL.md` — document new behavior in Core Logic
3. Update this file — record design decision

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-04-16 | Initial generated scaffold |
