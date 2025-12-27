#!/bin/bash

get_current_mode() {
    governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)

    case "$governor" in
        "performance") echo "Performance" ;;
        "powersave") echo "Powersaver" ;;
        "ondemand"|"schedutil"|"conservative") echo "Balanced" ;;
        *) echo "Unknown" ;;
    esac
}

change_power_mode() {
    mode=$1

    case "$mode" in
        "Performance") governor="performance" ;;
        "Balanced") governor="ondemand" ;;
        "Powersaver") governor="powersave" ;;
        *) zenity --error --text="Unrecognized mode."; exit 1 ;;
    esac

    pkexec bash -c "
        for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
            cpu_id=\${cpu##*cpu}
            cpufreq-set -c \$cpu_id -g $governor
        done
    " || {
        zenity --error --text="Failed to change power mode to: $mode"
        exit 1
    }

    zenity --info --title="Power Mode" --text="Power mode set to: $mode"
}

current_mode=$(get_current_mode)

mode=$(zenity --list \
    --width=500 --height=250 \
    --radiolist \
    --title="Power Mode Switcher" \
    --text="Choose the desired power mode (Current: $current_mode)" \
    --column="Select" --column="Mode" \
    FALSE "Performance" \
    FALSE "Balanced" \
    FALSE "Powersaver")

[ -z "$mode" ] && exit 0

change_power_mode "$mode"
