# openclaw-skill-generator

Generates a complete, production-ready OpenClaw AgentSkill scaffold from a simple description.

## When to Use

- A user asks to "create a skill", "write a skill for X", or "author a new agent skill"
- A new workflow needs to be automated but no skill exists yet
- During `/skill-creator` or `/clawhub publish` workflows

## How It Works

1. You describe the skill (name, purpose, tools needed)
2. The generator creates the full directory structure with all required files
3. Output conforms to the AgentSkills v1 spec and is immediately usable

## Generated Output

```
skill-name/
├── SKILL.md                    # Core spec + description + usage
├── scripts/
│   └── main.sh                 # Entry point script
└── references/
    └── overview.md             # Context and design notes
```

## Usage

```bash
bash openclaw-skill-generator/scripts/generate.sh \
  --name "my-skill" \
  --description "Does X and Y" \
  --tools "exec,write,read" \
  --author "Leslie" \
  --output ~/.openclaw/skills/my-skill/
```

Or interactively — just describe what you want and the generator will infer the rest.

## Example

**Input:**
```
Name: weather-alert
Purpose: Send weather warnings to a specific Feishu channel
Tools needed: exec (curl to weather API), feishu_im_user_message
Author: Leslie
```

**Output:** A complete `weather-alert/` skill scaffold with:
- `SKILL.md` with description, tool mapping, and cron example
- `scripts/main.sh` that fetches weather data and sends alerts
- `references/overview.md` with design decisions

## Generated SKILL.md Format

The generated SKILL.md always includes:

1. **Header** — skill name, description, author
2. **When to Use** — trigger conditions
3. **Core Logic** — step-by-step behavior
4. **Tools Used** — mapped tools and their roles
5. **Output** — what the skill produces
6. **Error Handling** — fallback behavior
7. **Cron Examples** — optional scheduled runs
8. **Notes** — caveats and version info

## Design Principles

- Never overwrite existing files without explicit user consent
- Always use the tool path from the available_skills list
- Always include a "When to Use" section for trigger clarity
- Scripts must be self-contained (no external dependencies beyond system tools)
- SKILL.md must be readable by both AI and humans

## Requirements

- `bash` 4+
- `python3` (for any templating logic)
- Standard Unix tools: `mkdir`, `cp`, `sed`
