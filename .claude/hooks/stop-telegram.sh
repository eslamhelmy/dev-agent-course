#!/bin/bash

# Stop Hook: Telegram Notification
# Fires on the "Stop" event -- sends a message to your phone when the agent finishes.
#
# Setup:
#   1. Create a Telegram bot via @BotFather
#   2. Send the bot a message to get your chat ID
#   3. Export these environment variables:
#      export TELEGRAM_BOT_TOKEN="your-bot-token"
#      export TELEGRAM_CHAT_ID="your-chat-id"
#   4. Install jq: brew install jq (macOS) or apt install jq (Linux)
#
# Register in .claude/settings.local.json:
#   { "hooks": { "Stop": [{ "type": "command", "command": "bash .claude/hooks/stop-telegram.sh" }] } }
#
# Exit codes:
#   0 = success (always exit 0 -- notifications should never block the agent)

TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID}"

# If credentials are not set, exit silently
if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
  exit 0
fi

# Read the stop hook input from stdin (JSON with stop_reason)
INPUT=$(cat)
STOP_REASON=$(echo "$INPUT" | jq -r '.stop_reason // "unknown"')

MESSAGE="Agent finished. Reason: ${STOP_REASON}"

# Send the notification (suppress output, never fail)
curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d chat_id="$TELEGRAM_CHAT_ID" \
  -d text="$MESSAGE" \
  -d parse_mode="Markdown" > /dev/null 2>&1

exit 0
