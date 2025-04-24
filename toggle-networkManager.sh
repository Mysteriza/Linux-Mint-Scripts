#!/bin/bash

# WiFi interface to manage
WIFI_IFACE="wlx18d6c70831ae"

# Get current NetworkManager status
nm_status=$(systemctl is-active NetworkManager)
if [ "$nm_status" == "active" ]; then
  nm_status_display="ACTIVE"
else
  nm_status_display="INACTIVE"
fi

# Check if interface is in monitor mode
iface_mode=$(iw dev "$WIFI_IFACE" info 2>/dev/null | grep -o 'type .*' | cut -d' ' -f2)
if [ "$iface_mode" == "monitor" ]; then
  monitor_status="ENABLED"
else
  monitor_status="DISABLED"
fi

# Show Zenity dialog
action=$(zenity --list \
  --title="Network & Monitor Mode Manager" \
  --width=600 --height=400 \
  --text="Current NetworkManager: $nm_status_display\nMonitor Mode: $monitor_status\n\nChoose an action:" \
  --radiolist \
  --column="Select" --column="Action" \
  FALSE "Enable Monitor Mode" \
  FALSE "Disable Monitor Mode & Restart NetworkManager" \
  TRUE "Restart NetworkManager Only")

# Execute based on user choice
case "$action" in
  "Enable Monitor Mode")
    pkexec bash -c "systemctl stop NetworkManager && ip link set $WIFI_IFACE down && iw dev $WIFI_IFACE set type monitor && ip link set $WIFI_IFACE up"
    zenity --info --title="Monitor Mode" --text="Monitor mode enabled successfully on $WIFI_IFACE."
    ;;

  "Disable Monitor Mode & Restart NetworkManager")
    pkexec bash -c "ip link set $WIFI_IFACE down && iw dev $WIFI_IFACE set type managed && ip link set $WIFI_IFACE up && systemctl start NetworkManager"
    zenity --info --title="Monitor Mode" --text="Monitor mode disabled and NetworkManager restarted."
    ;;

  "Restart NetworkManager Only")
    pkexec bash -c "systemctl stop NetworkManager && sleep 1 && systemctl start NetworkManager"
    zenity --info --title="NetworkManager" --text="NetworkManager has been restarted."
    ;;

  *)
    zenity --warning --title="No Action" --text="No action was selected."
    ;;
esac
