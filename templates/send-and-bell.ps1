# claude-doorbell -- A-side snippet (PowerShell version): place a letter and ring the bell.
#
# Which snippet to use: pick by the shell that B's SSH session lands in.
#   - This .ps1 sends remote commands that assume PowerShell on B
#     (Rename-Item / Set-Content / Get-Content). The default shell of
#     Windows OpenSSH is cmd.exe, so use this only if B's SSH lands in
#     PowerShell. If B is macOS/Linux, or its SSH lands in cmd.exe, use
#     the .sh version's style of commands instead -- see SKILL.md step 4.
#
# Usage:
#   .\send-and-bell.ps1 -Subject "<subject>" -Letter "<letter-file>"
#
# The letter file must be a Markdown file whose first lines are the
# from / to / date / type / reply headers. See the mailbox README for
# how to write the body.
#
# What it does:
#   1. Sends the letter to B's mailbox as <YYYYMMDD-HHMM_subject>.tmp
#   2. Renames it to .md (the "finished" signal; the other side never reads .tmp)
#   3. Rewrites _bell.txt in the destination folder with the current time (the bell that wakes B)
#   4. Reads the bell back to confirm it was written
param(
    [Parameter(Mandatory = $true)][string]$Subject,
    [Parameter(Mandatory = $true)][string]$Letter
)

$RemoteHost = "<ssh-host>"            # SSH target for B's machine (Tailscale name or IP)
$Mailbox    = "<remote-mailbox-path>" # Absolute path of the mailbox on B (e.g. C:\path\to\mailbox)
$ToDir      = "to-b"                  # Destination folder (letters for B)

$Name = (Get-Date -Format "yyyyMMdd-HHmm") + "_" + $Subject

scp $Letter "${RemoteHost}:$Mailbox/$ToDir/$Name.tmp"
ssh $RemoteHost "Rename-Item -Path '$Mailbox\$ToDir\$Name.tmp' -NewName '$Name.md'"
ssh $RemoteHost "Set-Content -Path '$Mailbox\$ToDir\_bell.txt' -Value (Get-Date -Format 'yyyy-MM-dd HH:mm') -Encoding UTF8"
Write-Output ("bell on B: " + (ssh $RemoteHost "Get-Content '$Mailbox\$ToDir\_bell.txt'"))
Write-Output "sent: $Name.md"
