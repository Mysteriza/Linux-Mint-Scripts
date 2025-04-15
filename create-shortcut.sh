#!/bin/bash

# Configuration
WIDTH=500
HEIGHT=400

# Prompt for Shortcut Name
SHORTCUT_NAME=$(zenity --entry --width=$WIDTH --height=$HEIGHT \
  --title="Create a Shortcut" \
  --text="Enter the name of your shortcut:")

[ -z "$SHORTCUT_NAME" ] && zenity --error --width=$WIDTH --text="Shortcut name is required!" && exit 1

# Prompt for Executable Path
EXEC_PATH=$(zenity --file-selection --width=$WIDTH --height=$HEIGHT \
  --title="Select Executable File")

[ -z "$EXEC_PATH" ] && zenity --error --width=$WIDTH --text="Executable path is required!" && exit 1

# Prompt for Icon File (Optional)
ICON_PATH=$(zenity --file-selection --width=$WIDTH --height=$HEIGHT \
  --title="Select an Icon (Optional)" --file-filter="Images | *.png *.xpm *.jpg *.svg")

# Prompt for Description (Optional)
DESCRIPTION=$(zenity --entry --width=$WIDTH --height=$HEIGHT \
  --title="Description" \
  --text="Enter a short description (optional):")

# Create the .desktop file
DESKTOP_FILE="$HOME/.local/share/applications/$SHORTCUT_NAME.desktop"

cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Type=Application
Name=$SHORTCUT_NAME
Exec="$EXEC_PATH"
Icon=${ICON_PATH:-utilities-terminal}
Comment=$DESCRIPTION
Terminal=false
Categories=Utility;
EOF

# Make it executable
chmod +x "$DESKTOP_FILE"

# Success message
zenity --info --width=$WIDTH --height=100 --title="Success" \
  --text="Shortcut '$SHORTCUT_NAME' has been created successfully!\nYou can find it in your application menu."

exit 0
