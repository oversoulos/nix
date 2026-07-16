#!/usr/bin/env bash
set -euo pipefail

cmd="${1:-all}"
case "$cmd" in
  net)
    nmcli general status
    nmcli connection show
    ping -c 3 1.1.1.1
    ;;
  logs)
    journalctl -p 3 -xb -n 100
    ;;
  proc)
    ps aux --sort=-%mem | head -n 20
    ;;
  nix)
    nix-store --verify --check-contents
    ;;
  modes)
    find "$HOME/modes" -maxdepth 2 -name .envrc -print -exec sed -n '1,120p' {} \;
    ;;
  all)
    "$0" net
    "$0" logs
    "$0" proc
    ;;
  *)
    echo "Usage: $0 {net|logs|proc|nix|modes|all}"
    exit 1
    ;;
esac
