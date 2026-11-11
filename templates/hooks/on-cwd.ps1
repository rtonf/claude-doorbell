# on-cwd.ps1 -- CwdChanged hook (sync)
# Re-registers the watch paths every time the working folder changes.
# Without this hook, Claude Code replaces the watch list with an empty one
# after a cd, and FileChanged stops firing until the next session.
# Replace the placeholders before use: <INBOX>, <LOG>
# PowerShell 5.1 reads BOM-less .ps1 files as ANSI: keep this file ASCII-only,
# or save it as UTF-8 with BOM.
$ErrorActionPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$null = [Console]::In.ReadToEnd()

$inbox = '<INBOX>'
$bell  = Join-Path $inbox '_bell.txt'
$log   = '<LOG>'

New-Item -ItemType Directory -Force (Split-Path $log) | Out-Null
Add-Content -LiteralPath $log -Value ("{0} cwd rearm" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))

$out = @{
    hookSpecificOutput = @{
        hookEventName = 'CwdChanged'
        watchPaths    = @($bell, $inbox)
    }
}
$out | ConvertTo-Json -Compress -Depth 5
exit 0
