#!/bin/bash

translate_status() {
  if [[ "$1" == "enabled" ]]; then echo "AKTIF"; else echo "TIDAK AKTIF"; fi
}

status_mariadb_raw=$(systemctl is-enabled mariadb 2>/dev/null)
status_mariadb=$(translate_status "$status_mariadb_raw")

# Perbaikan: Deteksi yang lebih akurat
if systemctl list-unit-files | grep -q "^apache2.service"; then
  web_service="apache2"
  status_phpmyadmin_raw=$(systemctl is-enabled apache2 2>/dev/null)
  status_phpmyadmin=$(translate_status "$status_phpmyadmin_raw")
elif systemctl list-unit-files | grep -q "^nginx.service"; then
  web_service="nginx"
  status_phpmyadmin_raw=$(systemctl is-enabled nginx 2>/dev/null)
  status_phpmyadmin=$(translate_status "$status_phpmyadmin_raw")
else
  zenity --error --text="Tidak ditemukan web server (apache2/nginx). phpMyAdmin tidak bisa diatur."
  exit 1
fi

action=$(zenity --list \
  --title="Manajer Service MariaDB & phpMyAdmin" \
  --text="Status MariaDB saat ini: $status_mariadb\nStatus phpMyAdmin saat ini: $status_phpmyadmin\n\nPilih tindakan:" \
  --radiolist \
  --column="Pilih" --column="Aksi" \
  FALSE "Aktifkan MariaDB dan phpMyAdmin" \
  FALSE "Matikan MariaDB dan phpMyAdmin" \
  --width=600 --height=300)

case "$action" in
  "Aktifkan MariaDB dan phpMyAdmin")
    pkexec bash -c "systemctl enable mariadb && systemctl start mariadb && systemctl enable $web_service && systemctl start $web_service"
    zenity --info --title="Status" --text="MariaDB dan phpMyAdmin telah diaktifkan."
    ;;
  "Matikan MariaDB dan phpMyAdmin")
    pkexec bash -c "systemctl stop mariadb && systemctl disable mariadb && systemctl stop $web_service && systemctl disable $web_service"
    zenity --info --title="Status" --text="MariaDB dan phpMyAdmin telah dimatikan."
    ;;
  *)
    zenity --warning --text="Tidak ada tindakan yang dipilih."
    ;;
esac
