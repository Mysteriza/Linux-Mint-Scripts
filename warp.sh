#!/bin/bash

while :; do
  # Check WARP status accurately
  STATUS=$(warp-cli status 2>/dev/null | grep "Status update" | awk '{print $3}')
  
  # Check if WARP is not registered
  if echo "$(warp-cli status 2>/dev/null)" | grep -q "Registration Missing"; then
    zenity --question --text="WARP is not registered.\n\nDo you want to register now?" --width=300
    if [[ $? -eq 0 ]]; then
      if warp-cli registration new >/dev/null 2>&1; then
        zenity --info --text="WARP registered successfully!" --width=250 --timeout=2
      else
        zenity --error --text="Failed to register WARP!\nPlease check your connection." --width=300
        exit 1
      fi
    else
      exit 0
    fi
    continue
  fi

  if [[ "$STATUS" == "Connected" ]]; then
    TXT="WARP: <b><span color='#44ff44'>● Connected</span></b>"
  else
    TXT="WARP: <b><span color='#ff4444'>○ Disconnected</span></b>"
  fi

  CHOICE=$(zenity --list --hide-header --width=350 --height=200 \
    --title="Cloudflare WARP" \
    --text="$TXT\n\nChoose Action:" \
    --column="Action" \
    "🟢 Connect WARP" \
    "🔴 Disconnect WARP" \
    "🚪 Exit")


  if [[ -z "$CHOICE" ]]; then
    exit 0
  fi

  case "$CHOICE" in
    "🟢 Connect WARP")
      if warp-cli connect >/dev/null 2>&1; then
        zenity --info --text="WARP Connected!" --width=200 --timeout=2
        exit 0
      else
        zenity --error --text="Failed to connect WARP!\nPlease try again." --width=250 --timeout=3

      fi
      ;;
    "🔴 Disconnect WARP")
      if warp-cli disconnect >/dev/null 2>&1; then
        zenity --info --text="WARP Disconnected" --width=200 --timeout=2
        exit 0
      else
        zenity --error --text="Failed to disconnect WARP!\nPlease try again." --width=250 --timeout=3

      fi
      ;;
    "🚪 Exit")
      exit 0
      ;;
  esac
done