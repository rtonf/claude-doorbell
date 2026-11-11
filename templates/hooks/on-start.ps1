# on-start.ps1 -- SessionStart hook (sync)
# Registers the watch paths (the bell file and the inbox folder) and tells
# Claude how many unread messages are waiting.
# Replace the placeholders before use: <INBOX>, <LOG>
# PowerShell 5.1 reads BOM-less .ps1 files as ANSI: keep this file ASCII-only,
# or save it as UTF-8 with BOM.
$ErrorActionPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$null = [Console]::In.ReadToEnd()

$inbox = '<INBOX>'
$bell  = Join-Path $inbox '_bell.txt'
$log   = '<LOG>'

$unread = @(Get-ChildItem -LiteralPath $inbox -File -Filter '*.md')
New-Item -ItemType Directory -Force (Split-Path $log) | Out-Null
Add-Content -LiteralPath $log -Value ("{0} start unread={1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $unread.Count)

$out = @{
    hookSpecificOutput = @{
        hookEventName     = 'SessionStart'
        watchPaths        = @($bell, $inbox)
        additionalContext = "mailbox: unread messages = $($unread.Count)."
    }
}
$out | ConvertTo-Json -Compress -Depth 5
exit 0
