#!/usr/bin/env bash
# on-cwd.sh -- CwdChanged hook (sync)
# Bash adaptation of on-cwd.ps1. UNTESTED: written for macOS/Linux users,
# verified only by reading, not by running. Check it before you rely on it.
# Re-registers the watch paths every time the working folder changes.
# Without this hook, Claude Code replaces the watch list with an empty one
# after a cd, and FileChanged stops firing until the next session.
# Replace the placeholders before use: <INBOX>, <LOG>
# Requires: jq

INBOX='<INBOX>'
BELL="$INBOX/_bell.txt"
LOG='<LOG>'

cat >/dev/null   # consume stdin

mkdir -p "$(dirname "$LOG")"
printf '%s cwd rearm\n' "$(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG"

jq -n --arg bell "$BELL" --arg inbox "$INBOX" \
  '{hookSpecificOutput: {hookEventName: "CwdChanged", watchPaths: [$bell, $inbox]}}'
exit 0
