#!/bin/bash

# Fungsi untuk mendeteksi mode daya aktif secara aktual dari CPU governor
get_current_mode() {
    governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)

    case "$governor" in
        "performance") echo "Performance" ;;
        "powersave") echo "Powersaver" ;;
        "ondemand"|"schedutil"|"conservative") echo "Balanced" ;;
        *) echo "Unknown" ;;
    esac
}

# Fungsi untuk mengatur mode daya menggunakan cpufreq-set
set_cpufreq_mode() {
    target_governor=$1

    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
        cpu_id=${cpu##*cpu}
        cpufreq-set -c "$cpu_id" -g "$target_governor" || return 1
    done
    return 0
}

# Fungsi untuk mengatur mode daya via pkexec dan cpufreq-set
change_power_mode() {
    mode=$1

    case "$mode" in
        "Performance") governor="performance" ;;
        "Balanced") governor="ondemand" ;;  # atau schedutil/conservative
        "Powersaver") governor="powersave" ;;
        *) zenity --error --text="Mode tidak dikenali."; exit 1 ;;
    esac

    # Gunakan pkexec untuk set governor
    pkexec bash -c "
        for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
            cpu_id=\${cpu##*cpu}
            cpufreq-set -c \$cpu_id -g $governor
        done
    " || {
        zenity --error --text="Gagal mengubah mode ke: $mode"
        exit 1
    }

    zenity --info --title="Power Mode" --text="Mode telah diatur ke: $mode"
}

# Menampilkan dialog Zenity untuk memilih mode
current_mode=$(get_current_mode)

mode=$(zenity --list \
    --width=500 --height=250 \
    --radiolist \
    --title="Power Mode Switcher" \
    --text="Pilih mode daya yang diinginkan (Saat ini: $current_mode)" \
    --column="Pilih" --column="Mode" \
    FALSE "Performance" \
    FALSE "Balanced" \
    FALSE "Powersaver")

# Jika user membatalkan pilihan
[ -z "$mode" ] && exit 0

# Jalankan perubahan mode
change_power_mode "$mode"
