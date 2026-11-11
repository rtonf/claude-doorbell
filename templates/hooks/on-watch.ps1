# on-watch.ps1 -- FileChanged hook (sync, diagnostics only)
# Logs which file changed, and returns the watch paths again.
# The wake-up works without this hook, but the log it writes is the single
# most useful thing when the setup does not behave. Keep it.
# Replace the placeholders before use: <INBOX>, <LOG>
# PowerShell 5.1 reads BOM-less .ps1 files as ANSI: keep this file ASCII-only,
# or save it as UTF-8 with BOM.
$ErrorActionPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$raw = [Console]::In.ReadToEnd()

$inbox = '<INBOX>'
$bell  = Join-Path $inbox '_bell.txt'
$log   = '<LOG>'

$name = '?'; $evt = '?'
try {
    $in = $raw | ConvertFrom-Json
    if ($in.file_path) { $name = Split-Path $in.file_path -Leaf }
    if ($in.event)     { $evt  = $in.event }
} catch {}
if ($name -notmatch '^[\w.\-]+$') { $name = 'other' }   # Do not copy sender-chosen names into the log

New-Item -ItemType Directory -Force (Split-Path $log) | Out-Null
Add-Content -LiteralPath $log -Value ("{0} watch file={1} event={2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $name, $evt)

$paths = @($bell, $inbox)
$out = @{
    watchPaths         = $paths
    hookSpecificOutput = @{ hookEventName = 'FileChanged'; watchPaths = $paths }
}
$out | ConvertTo-Json -Compress -Depth 5
exit 0
