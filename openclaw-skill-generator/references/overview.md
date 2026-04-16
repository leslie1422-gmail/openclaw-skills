# openclaw-skill-generator — Design Overview

## Purpose

Automatically generate a complete, production-ready OpenClaw AgentSkill scaffold from a simple description. Users should be able to describe what they want, and the generator handles the rest.

## Architecture

- **Entry**: `scripts/generate.sh` — called by OpenClaw agent or CLI
- **Spec**: `SKILL.md` — defines behavior for LLM consumption
- **Refs**: `references/` — human-readable design notes

## Design Decisions

1. **Why bash over Python?** — bash is available everywhere with no extra dependencies
2. **Why auto-detect tools?** — Less friction for users; just describe the skill
3. **Why template SKILL.md?** — Ensures consistency across all skills in the ecosystem
4. **Why JSON output in main.sh?** — OpenClaw agents parse JSON natively

## Extending

To add new template variables:
1. Add the variable to `generate.sh` with `{{VAR_NAME}}` syntax
2. Update this file with the new design decision

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-04-16 | Initial scaffold generator |
