#!/bin/bash

# Detect current active power mode from CPU governor
get_current_mode() {
    governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)

    case "$governor" in
        "performance") echo "Performance" ;;
        "powersave") echo "Powersaver" ;;
        "ondemand"|"schedutil"|"conservative") echo "Balanced" ;;
        *) echo "Unknown" ;;
    esac
}

# Set governor for each CPU core
set_cpufreq_mode() {
    target_governor=$1

    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
        cpu_id=${cpu##*cpu}
        cpufreq-set -c "$cpu_id" -g "$target_governor" || return 1
    done
    return 0
}

# Change power mode using pkexec
change_power_mode() {
    mode=$1

    case "$mode" in
        "Performance") governor="performance" ;;
        "Balanced") governor="ondemand" ;;  # could also be schedutil/conservative
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

# Show mode selection dialog
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

# Exit if no selection made
[ -z "$mode" ] && exit 0

# Apply selected power mode
change_power_mode "$mode"
