#!/bin/bash

status=$(systemctl is-active NetworkManager)
if [ "$status" == "active" ]; then
  status="ACTIVE"
else
  status="INACTIVE"
fi

# Show action dialog
action=$(zenity --list \
  --title="Restart NetworkManager" \
  --width=500 --height=200 \
  --text="Current NetworkManager status: $status\n\nSelect an action:" \
  --radiolist \
  --column="Select" --column="Action" \
  TRUE "Stop and Restart NetworkManager (Back to Normal)")

if [ "$action" == "Stop and Restart NetworkManager (Back to Normal)" ]; then
  pkexec bash -c "systemctl stop NetworkManager && sleep 1 && systemctl start NetworkManager"
  zenity --info --title="NetworkManager" --text="NetworkManager has been successfully restarted."
else
  zenity --warning --text="No action selected."
fi
