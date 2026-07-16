#!/usr/bin/env bash
set -euo pipefail

mode="vibing"
[[ -f "$HOME/.config/oversoul/active-mode" ]] && mode=$(cat "$HOME/.config/oversoul/active-mode")
ai_status="inactive"
if systemctl is-active --quiet koboldcpp 2>/dev/null; then
  ai_status="active"
fi

printf 'uptime=%s | mem=%s | mode=%s | ai=%s\n' \
  "$(uptime -p)" \
  "$(free -h | awk '/Mem:/ {print $3"/"$2}')" \
  "$mode" \
  "$ai_status"
