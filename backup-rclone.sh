#!/bin/bash

# Rclone Backup Script
# Remote: gdrive

# Color definitions
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[1;36m'
BOLD='\e[1m'
RESET='\e[0m'

declare -A backups=(
    ["Sounds"]="/home/mysteriza/D-Drive/Sounds:gdrive:Sounds"
    ["Project TA"]="/home/mysteriza/D-Drive/Project TA:gdrive:Project TA"
    # Add more here: ["Display Name"]="/local/path:gdrive:remote/path"
)

clear
echo -e "${CYAN}${BOLD}=======================================${RESET}"
echo -e "${CYAN}${BOLD}     RCLONE BACKUP MENU${RESET}"
echo -e "${CYAN}${BOLD}=======================================${RESET}"
echo
echo -e "${GREEN}Select backup target:${RESET}"
echo -e "${YELLOW}0) All directories${RESET}"
i=1
for name in "${!backups[@]}"; do
    echo -e "${YELLOW}$i) $name${RESET}"
    ((i++))
done
echo -e "${YELLOW}q) Quit${RESET}"
echo

read -p "Enter choice: " choice

if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
    echo -e "${RED}Bye!${RESET}"
    exit 0
elif [[ "$choice" == "0" ]]; then
    for name in "${!backups[@]}"; do
        IFS=':' read -r local remote <<< "${backups[$name]}"
        echo -e "${BLUE}${BOLD}---------------------------------------${RESET}"
        echo -e "${BLUE}Syncing $name ...${RESET}"
        rclone sync "$local" "$remote" --progress
        echo -e "${BLUE}${BOLD}---------------------------------------${RESET}"
    done
else
    i=1
    selected=0
    for name in "${!backups[@]}"; do
        if [[ "$i" == "$choice" ]]; then
            IFS=':' read -r local remote <<< "${backups[$name]}"
            echo -e "${BLUE}${BOLD}---------------------------------------${RESET}"
            echo -e "${BLUE}Syncing $name ...${RESET}"
            rclone sync "$local" "$remote" --progress
            echo -e "${BLUE}${BOLD}---------------------------------------${RESET}"
            selected=1
            break
        fi
        ((i++))
    done
    if [[ $selected -eq 0 ]]; then
        echo -e "${RED}Invalid choice!${RESET}"
    fi
fi

echo -e "${GREEN}${BOLD}Backup complete!${RESET}"
read -p "Press Enter to exit..."