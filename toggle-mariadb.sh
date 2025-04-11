#!/bin/bash

translate_status() {
  if [[ "$1" == "enabled" ]]; then echo "ENABLED"; else echo "DISABLED"; fi
}

status_mariadb_raw=$(systemctl is-enabled mariadb 2>/dev/null)
status_mariadb=$(translate_status "$status_mariadb_raw")

# Detect available web server (Apache or Nginx)
if systemctl list-unit-files | grep -q "^apache2.service"; then
  web_service="apache2"
  status_phpmyadmin_raw=$(systemctl is-enabled apache2 2>/dev/null)
  status_phpmyadmin=$(translate_status "$status_phpmyadmin_raw")
elif systemctl list-unit-files | grep -q "^nginx.service"; then
  web_service="nginx"
  status_phpmyadmin_raw=$(systemctl is-enabled nginx 2>/dev/null)
  status_phpmyadmin=$(translate_status "$status_phpmyadmin_raw")
else
  zenity --error --text="No web server found (apache2/nginx). phpMyAdmin cannot be managed."
  exit 1
fi

# Show service options
action=$(zenity --list \
  --title="MariaDB & phpMyAdmin Service Manager" \
  --text="MariaDB status: $status_mariadb\nphpMyAdmin (via $web_service) status: $status_phpmyadmin\n\nSelect an action:" \
  --radiolist \
  --column="Select" --column="Action" \
  FALSE "Enable MariaDB and phpMyAdmin" \
  FALSE "Disable MariaDB and phpMyAdmin" \
  --width=600 --height=300)

# Perform the selected action
case "$action" in
  "Enable MariaDB and phpMyAdmin")
    pkexec bash -c "systemctl enable mariadb && systemctl start mariadb && systemctl enable $web_service && systemctl start $web_service"
    zenity --info --title="Status" --text="MariaDB and phpMyAdmin have been enabled."
    ;;
  "Disable MariaDB and phpMyAdmin")
    pkexec bash -c "systemctl stop mariadb && systemctl disable mariadb && systemctl stop $web_service && systemctl disable $web_service"
    zenity --info --title="Status" --text="MariaDB and phpMyAdmin have been disabled."
    ;;
  *)
    zenity --warning --text="No action selected."
    ;;
esac
