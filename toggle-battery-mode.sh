#!/bin/bash

# Check if Zenity is installed
if ! command -v zenity &> /dev/null; then
    echo "Zenity not found. Please install it with: sudo apt install zenity"
    exit 1
fi

# Get current battery charging mode
current_mode=$(cat /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode)

if [[ "$current_mode" == "1" ]]; then
    status_text="Current mode: Charging is limited (max 60%)"
else
    status_text="Current mode: Charging to full (max 100%)"
fi

# Show battery mode options
choice=$(zenity --list \
  --title="Lenovo Battery - Conservation Mode" \
  --text="$status_text\n\nSelect your preferred battery charging mode:" \
  --radiolist \
  --column="Select" --column="Mode" \
  TRUE "Limit charging to (max 60%)" \
  FALSE "Charge fully to (max 100%)" \
  --width=450 --height=250)

# Apply selected option
if [[ "$choice" == "Limit charging to (max 60%)" ]]; then
    pkexec bash -c "echo 1 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode"
    zenity --info --text="Charging will now be limited to about 60%."
elif [[ "$choice" == "Charge fully to (max 100%)" ]]; then
    pkexec bash -c "echo 0 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode"
    zenity --info --text="Charging will now continue to 100%."
else
    zenity --warning --text="No option selected."
fi
