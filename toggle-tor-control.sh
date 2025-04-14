#!/bin/bash

WIDTH=500
HEIGHT=400

check_status() {
  systemctl is-active tor > /dev/null 2>&1
}

status_message() {
  if check_status; then
    echo "TOR service is currently: ACTIVE"
  else
    echo "TOR service is currently: INACTIVE"
  fi
}

ACTION=$(zenity --width=$WIDTH --height=$HEIGHT --list --radiolist \
  --title="TOR Service Control" \
  --text="$(status_message)\n\nChoose an action:" \
  --column "Select" --column "Action" \
  TRUE "Enable TOR" FALSE "Disable TOR" FALSE "Exit")

case "$ACTION" in
  "Enable TOR")
    bash -c 'pkexec systemctl start tor' && \
      zenity --info --width=$WIDTH --title="Success" --text="TOR service has been enabled!" || \
      zenity --error --width=$WIDTH --title="Error" --text="Failed to start TOR."
    ;;
  "Disable TOR")
    bash -c 'pkexec systemctl stop tor' && \
      zenity --info --width=$WIDTH --title="Success" --text="TOR service has been disabled!" || \
      zenity --error --width=$WIDTH --title="Error" --text="Failed to stop TOR."
    ;;
  *)
    exit 0
    ;;
esac
