#!/bin/bash

# PreToolUse Hook: Permission Gate
# Fires before every tool call -- blocks dangerous operations.
#
# What it blocks:
#   - Force pushes to main/master (exit 2 = block)
#   - Recursive delete from root (exit 2 = block)
#
# Register in .claude/settings.local.json:
#   { "hooks": { "PreToolUse": [{ "type": "command", "command": "bash .claude/hooks/permission-gate.sh" }] } }
#
# Exit codes:
#   0 = allow the operation
#   1 = warn but continue
#   2 = block the operation entirely

# Read PreToolUse hook input from stdin (JSON with tool_name and tool_input)
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // {}')

# Only inspect Bash tool calls
if [ "$TOOL_NAME" = "Bash" ]; then
  COMMAND=$(echo "$TOOL_INPUT" | jq -r '.command // ""')

  # Block force pushes to main/master
  if echo "$COMMAND" | grep -qE 'git\s+push.*--force.*(main|master)'; then
    echo "BLOCKED: Force push to main/master is not allowed."
    exit 2
  fi

  # Block recursive delete from root
  if echo "$COMMAND" | grep -qE 'rm\s+-rf\s+/'; then
    echo "BLOCKED: Recursive delete from root is not allowed."
    exit 2
  fi
fi

exit 0
