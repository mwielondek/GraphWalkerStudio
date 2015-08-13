#!/bin/bash
if ! command -v riot >/dev/null 2>&1; then
  echo "[!] Riot compiler required. Install with 'npm install riot -g'." >&2
  exit 1
else
  echo "[*] Compiling riot tags"
  cd "scripts/tags"
  ./compile.sh js && echo "[✓] Done." || echo "[✗] Error occured."
fi
