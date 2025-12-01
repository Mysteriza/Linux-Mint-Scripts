#!/bin/bash

while :; do
  STATUS=$(warp-cli status 2>/dev/null | grep "Status update" | awk '{print $3}')

  if [[ "$STATUS" == "Connected" ]]; then
    TXT="WARP: <b><span color='#44ff44'>● Connected</span></b>"
  else
    TXT="WARP: <b><span color='#ff4444'>○ Disconnected</span></b>"
  fi

  CHOICE=$(zenity --list --hide-header --width=350 --height=200 \
    --title="Cloudflare WARP" \
    --text="$TXT\n\nPilih aksi:" \
    --column="Aksi" \
    "🟢 Connect WARP" \
    "🔴 Disconnect WARP" \
    "🚪 Exit")

  case "$CHOICE" in
    "🟢 Connect WARP")
      warp-cli connect >/dev/null 2>&1
      zenity --info --text="WARP Connected!" --width=200 --timeout=2
      exit 0
      ;;
    "🔴 Disconnect WARP")
      warp-cli disconnect >/dev/null 2>&1
      zenity --info --text="WARP Disconnected" --width=200 --timeout=2
      exit 0
      ;;
    "🚪 Keluar dari Controller"|*)
      exit 0
  esac
done