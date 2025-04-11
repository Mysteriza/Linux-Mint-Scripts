#!/bin/bash

status=$(systemctl is-active NetworkManager)
if [ "$status" == "active" ]; then
  status="AKTIF"
else
  status="TIDAK AKTIF"
fi

action=$(zenity --list \
  --title="Restart NetworkManager" \
  --width=500 --height=200 \
  --text="Status NetworkManager saat ini: $status\n\nPilih tindakan:" \
  --radiolist \
  --column="Pilih" --column="Aksi" \
  TRUE "Stop dan Restart NetworkManager (Kembali Normal)")

if [ "$action" == "Stop dan Restart NetworkManager (Kembali Normal)" ]; then
  pkexec bash -c "systemctl stop NetworkManager && sleep 1 && systemctl start NetworkManager"
  zenity --info --title="NetworkManager" --text="NetworkManager berhasil dihentikan dan dijalankan kembali."
else
  zenity --warning --text="Tidak ada tindakan yang dipilih."
fi
