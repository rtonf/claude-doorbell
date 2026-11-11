# claude-doorbell — A 側スニペット（PowerShell 版）: 手紙を置いてベルを鳴らす
#
# 使い方:
#   .\send-and-bell.ps1 -Subject "<件名>" -Letter "<手紙ファイル>"
#
# 手紙ファイルは、from / to / date / type / reply のヘッダを書いた
# Markdown を用意しておくこと。本文の書き方はメールボックスの README 参照。
#
# やっていること:
#   1. 手紙を <YYYYMMDD-HHMM_件名>.tmp として B 側メールボックスへ送る
#   2. .md に改名する（完成の合図。相手は .tmp を読まない）
#   3. 宛先フォルダの中の _bell.txt を現在時刻で書き換える（相手を起こすベル）
#   4. ベルを読み戻して、書けたことを確認する
param(
    [Parameter(Mandatory = $true)][string]$Subject,
    [Parameter(Mandatory = $true)][string]$Letter
)

$RemoteHost = "<ssh-host>"            # B 側マシンへの SSH 接続先（Tailscale の名前や IP）
$Mailbox    = "<remote-mailbox-path>" # B 側メールボックスの絶対パス（例: C:\path\to\mailbox）
$ToDir      = "to-b"                  # 宛先フォルダ（B 宛）

$Name = (Get-Date -Format "yyyyMMdd-HHmm") + "_" + $Subject

scp $Letter "${RemoteHost}:$Mailbox/$ToDir/$Name.tmp"
ssh $RemoteHost "Rename-Item -Path '$Mailbox\$ToDir\$Name.tmp' -NewName '$Name.md'"
ssh $RemoteHost "Set-Content -Path '$Mailbox\$ToDir\_bell.txt' -Value (Get-Date -Format 'yyyy-MM-dd HH:mm') -Encoding UTF8"
Write-Output ("bell on B: " + (ssh $RemoteHost "Get-Content '$Mailbox\$ToDir\_bell.txt'"))
Write-Output "sent: $Name.md"
