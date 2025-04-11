# CUSTOM SCRIPTS

Custom Linux Mint scripts for personal use on some of the available features of the [Lenovo Ideapad Slim 3](https://psref.lenovo.com/syspool/Sys/PDF/IdeaPad/IdeaPad_3_14ARE05/IdeaPad_3_14ARE05_Spec.PDF).

**Notes**
1. These scripts are optimized for [Lenovo Ideapad Slim 3 running Linux Mint](https://termbin.com/1xvl) (you may have to customize the script to run on your computer)
2. Some scripts require root privileges and will prompt you via pkexec.
3. Tested on Linux Mint 22.1 (based on Ubuntu 24.04 LTS).

---

## 1. Power Mode Switcher  
<img src="https://github.com/user-attachments/assets/f84b0c1a-9f60-4365-b2b9-e4030377dffe" width="450"/>

This script allows you to switch between different CPU power modes:

- **Performance** — maximum CPU speed
- **Balanced** — medium power and speed
- **Powersaver** — minimum power usage

It uses `cpufreq-set` and applies the selected governor across all CPU cores. Root access is requested via `pkexec`.

---

## 2. Toggle Battery Mode  
<img src="https://github.com/user-attachments/assets/be9f211e-52ff-4bf2-9526-0e53fc3d6a37" width="450"/>

This script toggles the **Battery Conservation Mode** on supported Lenovo laptops:

- When **enabled**, battery charging is limited to 60% to extend battery lifespan.
- When **disabled**, the battery charges up to 100%.

The script reads and updates the conservation mode through `/sys/bus/platform/.../conservation_mode` with `pkexec`.

---

## 3. Toggle MariaDB and phpMyAdmin  
<img src="https://github.com/user-attachments/assets/1a8e2e82-d6d0-4e58-97cf-0fa2c4112e59" width="450"/>

This script controls the system services for **MariaDB** and **phpMyAdmin**:

- You can **enable/start** or **disable/stop** both services at once.
- Automatically detects if Apache2 or Nginx is installed as the web server.

Perfect for local development when you need to toggle your database environment quickly.

---

## 4. Restart NetworkManager  
<img src="https://github.com/user-attachments/assets/a045383b-b9ab-4d5c-a7fa-505428e4d16a" width="450"/>

A simple utility to **restart NetworkManager**, which can help fix common connection issues:

- Shows the current status of NetworkManager
- Stops and restarts the service using `pkexec`

This avoids the need to reboot your machine when the network gets stuck or misbehaves.

---

## Requirements

Ensure the following packages are installed:

- `zenity` — for displaying GUI dialogs
- `cpufrequtils` — for setting CPU governor
- `pkexec` — to perform actions with elevated privileges (usually provided by `policykit-1`)

Install them via:

```bash
sudo apt install zenity cpufrequtils policykit-1
