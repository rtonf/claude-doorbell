#!/usr/bin/env bash
# claude-doorbell — A 側スニペット（bash 版）: 手紙を置いてベルを鳴らす
#
# 使い方:
#   ./send-and-bell.sh <件名> <手紙ファイル>
#
# 手紙ファイルは、from / to / date / type / reply のヘッダを書いた
# Markdown を用意しておくこと。本文の書き方はメールボックスの README 参照。
#
# やっていること:
#   1. 手紙を <YYYYMMDD-HHMM_件名>.tmp として B 側メールボックスへ送る
#   2. .md に改名する（完成の合図。相手は .tmp を読まない）
#   3. 宛先フォルダの中の _bell.txt を現在時刻で書き換える（相手を起こすベル）
#   4. ベルを読み戻して、書けたことを確認する
set -euo pipefail

REMOTE_HOST="<ssh-host>"          # B 側マシンへの SSH 接続先（Tailscale の名前や IP）
MAILBOX="<remote-mailbox-path>"   # B 側メールボックスの絶対パス
TO_DIR="to-b"                     # 宛先フォルダ（B 宛。A 宛の返事を受け取る側が B なら to-a）

SUBJECT="${1:?件名が必要です}"
LETTER="${2:?手紙ファイルが必要です}"

STAMP="$(date '+%Y%m%d-%H%M')"
NAME="${STAMP}_${SUBJECT}"

scp "${LETTER}" "${REMOTE_HOST}:${MAILBOX}/${TO_DIR}/${NAME}.tmp"
ssh "${REMOTE_HOST}" "mv '${MAILBOX}/${TO_DIR}/${NAME}.tmp' '${MAILBOX}/${TO_DIR}/${NAME}.md'"
ssh "${REMOTE_HOST}" "printf '%s\n' \"\$(date '+%Y-%m-%d %H:%M')\" > '${MAILBOX}/${TO_DIR}/_bell.txt'"
echo "bell on B: $(ssh "${REMOTE_HOST}" "cat '${MAILBOX}/${TO_DIR}/_bell.txt'")"
echo "sent: ${NAME}.md"
