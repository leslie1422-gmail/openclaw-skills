#!/usr/bin/env bash
#===========================================================
# openclaw-skill-generator
# Generates a complete OpenClaw AgentSkill scaffold
#
# Usage:
#   bash generate.sh --name "my-skill" --description "..." [options]
#
# Options:
#   --name        Skill directory name (required)
#   --description One-line description (required)
#   --purpose     Multi-line purpose text (optional, inferred if omitted)
#   --tools       Comma-separated tool list (optional, inferred from description)
#   --author      Author name (optional, defaults to "OpenClaw")
#   --output      Output directory (optional, defaults to ~/.openclaw/skills/)
#   --force       Overwrite if skill already exists
#===========================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTHOR="OpenClaw"
OUTPUT_DIR="${HOME}/.openclaw/skills"
FORCE=false

#------------------------------------------------------------
# Argument parsing
#------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)        SKILL_NAME="$2";      shift 2 ;;
    --description) SKILL_DESC="$2";      shift 2 ;;
    --purpose)     SKILL_PURPOSE="$2";   shift 2 ;;
    --tools)       SKILL_TOOLS="$2";     shift 2 ;;
    --author)      AUTHOR="$2";            shift 2 ;;
    --output)      OUTPUT_DIR="$2";      shift 2 ;;
    --force)       FORCE=true;           shift ;;
    -h|--help)     cat <<'EOF'
openclaw-skill-generator

Usage:
  bash generate.sh --name "my-skill" --description "Does X and Y"

Options:
  --name        Skill directory name (required)
  --description One-line description (required)
  --purpose     Multi-line purpose (optional)
  --tools       Comma-separated tools (optional, auto-detected)
  --author      Author name (optional, default: OpenClaw)
  --output      Output directory (optional, default: ~/.openclaw/skills/)
  --force       Overwrite if skill already exists
EOF
               exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

#------------------------------------------------------------
# Validate required args
#------------------------------------------------------------
if [[ -z "${SKILL_NAME:-}" ]]; then
  echo "ERROR: --name is required"
  exit 1
fi
if [[ -z "${SKILL_DESC:-}" ]]; then
  echo "ERROR: --description is required"
  exit 1
fi

# Sanitize name (lowercase, no spaces)
SKILL_SLUG="$(echo "$SKILL_NAME" | sed 's/[^a-zA-Z0-9_-]/-/g' | tr '[:upper:]' '[:lower:]')"
SKILL_DIR="${OUTPUT_DIR}/${SKILL_SLUG}"

# Auto-detect tools from description if not provided
if [[ -z "${SKILL_TOOLS:-}" ]]; then
  DESC_LOWER="$(echo "$SKILL_DESC" | tr '[:upper:]' '[:lower:]')"
  DETECTED_TOOLS=()

  # Tool keyword mapping
  declare -A TOOL_KEYWORDS=(
    ["exec"]="run|execute|bash|shell|command"
    ["write"]="write|create|file|save"
    ["read"]="read|load|fetch|get"
    ["edit"]="edit|modify|update|change"
    ["browser"]="browse|web|chrome|page"
    ["message"]="send|notify|message|telegram|feishu"
    ["feishu"]="feishu|lark|飞书"
    ["tavily"]="search|web search|tavily"
    ["cron"]="schedule|cron|定时|periodic"
    ["pdf"]="pdf|document"
    ["image"]="image|generate|图片"
    ["tts"]="tts|voice|speech|语音"
    ["memory"]="memory|remember|记忆"
    ["wiki"]="wiki|knowledge|知识库"
  )

  for tool in "${!TOOL_KEYWORDS[@]}"; do
    if echo "$DESC_LOWER" | grep -qe "${TOOL_KEYWORDS[$tool]}"; then
      DETECTED_TOOLS+=("$tool")
    fi
  done

  SKILL_TOOLS="${DETECTED_TOOLS[*]:-exec,read,write}"
else
  SKILL_TOOLS="$(echo "$SKILL_TOOLS" | sed 's/,/", "/g')"
fi

# Auto-generate purpose if not provided
if [[ -z "${SKILL_PURPOSE:-}" ]]; then
  SKILL_PURPOSE="This skill is used for: ${SKILL_DESC}"
fi

#------------------------------------------------------------
# Check existing
#------------------------------------------------------------
if [[ -d "$SKILL_DIR" ]] && [[ "$FORCE" == false ]]; then
  echo "ERROR: $SKILL_DIR already exists. Use --force to overwrite."
  exit 1
fi

#------------------------------------------------------------
# Create directory structure
#------------------------------------------------------------
SKILL_DATE="$(date '+%Y-%m-%d')"
mkdir -p "$SKILL_DIR/scripts"
mkdir -p "$SKILL_DIR/references"

#=============================================================
# Generate SKILL.md
#=============================================================
cat > "$SKILL_DIR/SKILL.md" <<EOF
# ${SKILL_NAME}

${SKILL_DESC}

## When to Use

When a user asks to perform tasks related to: **${SKILL_DESC}**

## Core Logic

1. Receive user request with context
2. Validate required parameters
3. Execute primary action using: ${SKILL_TOOLS}
4. Format and return results
5. Handle errors gracefully with fallback

## Tools Used

| Tool | Purpose |
|------|---------|
EOF

# Add tools table rows
IFS=',' read -ra TOOL_ARRAY <<< "${SKILL_TOOLS}"
for tool in "${TOOL_ARRAY[@]}"; do
  tool="$(echo "$tool" | sed 's/^ *//;s/ *$//')"
  echo "| \`$tool\` | $(echo "$tool" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1))substr($i,2); print}') |" >> "$SKILL_DIR/SKILL.md"
done

cat >> "$SKILL_DIR/SKILL.md" <<EOF

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

\`\`\`json
{
  "schedule": { "kind": "cron", "expr": "0 9 * * *", "tz": "Asia/Shanghai" },
  "payload": { "kind": "agentTurn", "message": "Run ${SKILL_NAME}" }
}
\`\`\`

## Author

${AUTHOR}

## Last Updated

${SKILL_DATE}
EOF

#=============================================================
# Generate main.sh
#=============================================================
cat > "$SKILL_DIR/scripts/main.sh" <<"MAINEOF"
#!/usr/bin/env bash
#===========================================================
# SKILL_NAME_PLACEHOLDER - Entry point
# Generated by openclaw-skill-generator on DATE_PLACEHOLDER
#===========================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
SKILL_NAME="$(basename "$SKILL_DIR")"

#------------------------------------------------------------
# Configuration
#------------------------------------------------------------
LOG_FILE="${HOME}/.openclaw/logs/${SKILL_NAME}.log"
mkdir -p "$(dirname "$LOG_FILE")"

#------------------------------------------------------------
# Logging
#------------------------------------------------------------
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

error() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*"| tee -a "$LOG_FILE" >&2
}

#------------------------------------------------------------
# Main logic — replace with your implementation
#------------------------------------------------------------
main() {
  log "Starting ${SKILL_NAME}"

  # TODO: Implement skill logic here
  # Example:
  # local input="$1"
  # exec_tool --input "$input"
  # format_output

  echo '{"status":"success","message":"TODO: implement skill logic"}'
}

#------------------------------------------------------------
# Run
#------------------------------------------------------------
main "$@"
MAINEOF

chmod +x "$SKILL_DIR/scripts/main.sh"

#=============================================================
# Generate references/overview.md
#=============================================================
cat > "$SKILL_DIR/references/overview.md" <<EOF
# ${SKILL_NAME} — Design Overview

## Purpose

${SKILL_PURPOSE}

## Architecture

- **Entry**: \`scripts/main.sh\` — called by OpenClaw cron or agent
- **Spec**: \`SKILL.md\` — defines behavior for LLM consumption
- **Refs**: \`references/\` — human-readable design notes

## Design Decisions

1. **Why bash over Python?** — bash is available everywhere with no extra dependencies
2. **Why JSON output?** — OpenClaw agents parse JSON natively
3. **Why log file?** — enables debugging and audit trail

## Extending

To add new capabilities:
1. Edit \`scripts/main.sh\` — add new functions
2. Update \`SKILL.md\` — document new behavior in Core Logic
3. Update this file — record design decision

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | ${SKILL_DATE} | Initial generated scaffold |
EOF

#=============================================================
# Done
#=============================================================
echo ""
echo "✅ Skill generated successfully!"
echo ""
echo "📁 Location: $SKILL_DIR"
echo ""
echo "Contents:"
ls -la "$SKILL_DIR"
echo ""
ls -la "$SKILL_DIR/scripts"
echo ""
ls -la "$SKILL_DIR/references"
echo ""
echo "Next steps:"
echo "  1. Edit $SKILL_DIR/SKILL.md — customize behavior"
echo "  2. Edit $SKILL_DIR/scripts/main.sh — implement logic"
echo "  3. Test with: bash $SKILL_DIR/scripts/main.sh"
echo ""
