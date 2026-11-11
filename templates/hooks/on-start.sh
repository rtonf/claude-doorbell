#!/usr/bin/env bash
# on-start.sh -- SessionStart hook (sync)
# Bash adaptation of on-start.ps1. UNTESTED: written for macOS/Linux users,
# verified only by reading, not by running. Check it before you rely on it.
# Registers the watch paths (the bell file and the inbox folder) and tells
# Claude how many unread messages are waiting.
# Replace the placeholders before use: <INBOX>, <LOG>
# Requires: jq

INBOX='<INBOX>'
BELL="$INBOX/_bell.txt"
LOG='<LOG>'

cat >/dev/null   # consume stdin

mkdir -p "$(dirname "$LOG")"
count=$(find "$INBOX" -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
printf '%s start unread=%s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$count" >> "$LOG"

jq -n --arg bell "$BELL" --arg inbox "$INBOX" --arg ctx "mailbox: unread messages = $count." \
  '{hookSpecificOutput: {hookEventName: "SessionStart", watchPaths: [$bell, $inbox], additionalContext: $ctx}}'
exit 0
