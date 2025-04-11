#!/bin/bash

# Mengecek apakah Zenity tersedia
if ! command -v zenity &> /dev/null; then
    echo "Zenity tidak ditemukan. Silakan install dengan: sudo apt install zenity"
    exit 1
fi

# Mengecek status saat ini dari conservation_mode
current_mode=$(cat /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode)

if [[ "$current_mode" == "1" ]]; then
    status_text="Saat ini: Charging dibatasi (maks 60%)"
else
    status_text="Saat ini: Charging sampai penuh (maks 100%)"
fi

# Menampilkan dialog pilihan
choice=$(zenity --list \
  --title="Baterai Lenovo - Conservation Mode" \
  --text="$status_text\n\nPilih mode pengisian baterai:" \
  --radiolist \
  --column="Pilih" --column="Mode" \
  TRUE "Batasi Charging ke (maks 60%)" \
  FALSE "Charging ke (maks 100%)" \
  --width=450 --height=250)

# Mengeksekusi sesuai pilihan
if [[ "$choice" == "Batasi Charging ke (maks 60%)" ]]; then
    pkexec bash -c "echo 1 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode"
    zenity --info --text="Charging dibatasi sekitar 60%."
elif [[ "$choice" == "Charging ke (maks 100%)" ]]; then
    pkexec bash -c "echo 0 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode"
    zenity --info --text="Charging sampai 100%."
else
    zenity --warning --text="Tidak ada pilihan yang dipilih."
fi
