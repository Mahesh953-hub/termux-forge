#!/data/data/com.termux/files/usr/bin/bash
# Render one banner text-style with sample data. Used by fzf --preview.
# Sourced by termux-forge's tf_style_show; safe to run standalone.

style="$1"
[ -z "$style" ] && { echo "(no style)"; exit 0; }

# Locate termux-forge: this file lives beside the forge script.
self="${BASH_SOURCE[0]}"
dir="$(cd "$(dirname "$self")" && pwd)"
forge="$dir/termux-forge"
[ -f "$forge" ] || forge="$dir/../termux-forge"

# Pull just the tf_style_lines() function out of the forge script.
body_fn="$(sed -n '/^tf_style_lines()/,/^}/p' "$forge")"
if [ -z "$body_fn" ]; then
  echo "(style preview unavailable)"
  exit 0
fi

lines="$(printf '%s\n' "$body_fn" | bash -c '
  eval "$(cat)"
  tf_style_lines "$1"
' _ "$style")"

[ -z "$lines" ] && { echo "(no preview)"; exit 0; }

bash -c '
R=$'"'"'\033[1;31m'"'"'; G=$'"'"'\033[1;32m'"'"'; Y=$'"'"'\033[1;33m'"'"'
C=$'"'"'\033[1;36m'"'"'; W=$'"'"'\033[1;37m'"'"'; D=$'"'"'\033[2m'"'"'; N=$'"'"'\033[0m'"'"'
C_ART=$'"'"'\033[38;5;103m'"'"'; C_LBL=$'"'"'\033[38;5;60m'"'"'
C_TXT=$'"'"'\033[38;5;250m'"'"'; C_GRY=$'"'"'\033[38;5;240m'"'"'
TF_USER=kailashhh; TF_HOST=localhost; TF_MODEL="realme 5s"; TF_SYSTEM=17
TF_KERNEL=4.14.357; TF_UPTIME="3h 12m"; TF_BATTERY="84%"
TF_SHELLV=5.9.2; TF_PKGS=302; TF_RAM="2.8G / 3.6G"
TF_DISK="25G/109G"; TF_IP=192.168.1.5; TF_DATE="2026-09-30 18:52"
TF_TEXT_LINES=()
'"$lines"'
printf "%s\n" "${TF_TEXT_LINES[@]}"
' 2>/dev/null
