#!/bin/bash

# Rclone Backup Script - Simple Version

# Colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[1;36m'
BOLD='\e[1m'
RESET='\e[0m'

# Format: ["Nama Tampil"]="path lokal|gdrive:folder remote"
declare -A backups=(
    ["Sounds"]="/home/mysteriza/D-Drive/Sounds|gdrive:Sounds"
    # Tambah di sini nanti, contoh: ["Foto"]="/home/mysteriza/Pictures|gdrive:Foto"
)

clear
echo -e "${CYAN}${BOLD}=======================================${RESET}"
echo -e "${CYAN}${BOLD}     RCLONE BACKUP MENU${RESET}"
echo -e "${CYAN}${BOLD}=======================================${RESET}"
echo
echo -e "${GREEN}Pilih backup:${RESET}"
echo -e "${YELLOW}0) Semua folder${RESET}"
i=1
for name in "${!backups[@]}"; do
    echo -e "${YELLOW}$i) $name${RESET}"
    ((i++))
done
echo -e "${YELLOW}q) Keluar${RESET}"
echo

read -p "Masukin pilihan: " choice

if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
    echo -e "${RED}Bye bro!${RESET}"
    exit 0
elif [[ "$choice" == "0" ]]; then
    for name in "${!backups[@]}"; do
        IFS='|' read -r local remote <<< "${backups[$name]}"
        echo -e "${BLUE}${BOLD}---------------------------------------${RESET}"
        echo -e "${BLUE}Sync $name ...${RESET}"
        rclone sync "$local" "$remote" --progress
        echo ""
        sleep 0.2
        echo -e "${BLUE}${BOLD}---------------------------------------${RESET}"
    done
else
    i=1
    selected=0
    for name in "${!backups[@]}"; do
        if [[ "$i" == "$choice" ]]; then
            IFS='|' read -r local remote <<< "${backups[$name]}"
            echo -e "${BLUE}${BOLD}---------------------------------------${RESET}"
            echo -e "${BLUE}Sync $name ...${RESET}"
            rclone sync "$local" "$remote" --progress
            echo ""
            sleep 0.2
            echo -e "${BLUE}${BOLD}---------------------------------------${RESET}"
            selected=1
            break
        fi
        ((i++))
    done
    if [[ $selected -eq 0 ]]; then
        echo -e "${RED}Pilihan salah bro!${RESET}"
    fi
fi

echo -e "${GREEN}${BOLD}Backup selesai!${RESET}"
read -p "Tekan Enter buat keluar..."