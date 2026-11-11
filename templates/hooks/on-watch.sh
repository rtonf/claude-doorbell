#!/usr/bin/env bash
# on-watch.sh -- FileChanged hook (sync, diagnostics only)
# Bash adaptation of on-watch.ps1. UNTESTED: written for macOS/Linux users,
# verified only by reading, not by running. Check it before you rely on it.
# Logs which file changed, and returns the watch paths again.
# The wake-up works without this hook, but the log it writes is the single
# most useful thing when the setup does not behave. Keep it.
# Replace the placeholders before use: <INBOX>, <LOG>
# Requires: jq

INBOX='<INBOX>'
BELL="$INBOX/_bell.txt"
LOG='<LOG>'

raw=$(cat)

name='?'; evt='?'
fp=$(printf '%s' "$raw" | jq -r '.file_path // empty' 2>/dev/null)
ev=$(printf '%s' "$raw" | jq -r '.event // empty' 2>/dev/null)
[ -n "$fp" ] && name=$(basename "$fp")
[ -n "$ev" ] && evt="$ev"
# Do not copy sender-chosen names into the log
printf '%s' "$name" | grep -Eq '^[A-Za-z0-9_.-]+$' || name='other'

mkdir -p "$(dirname "$LOG")"
printf '%s watch file=%s event=%s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$name" "$evt" >> "$LOG"

jq -n --arg bell "$BELL" --arg inbox "$INBOX" \
  '{watchPaths: [$bell, $inbox], hookSpecificOutput: {hookEventName: "FileChanged", watchPaths: [$bell, $inbox]}}'
exit 0
