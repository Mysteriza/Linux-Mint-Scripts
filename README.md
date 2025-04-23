[![Visitors](https://visitor-badge.laobi.icu/badge?page_id=Mysteriza.Linux-Mint-Scripts)](https://github.com/Mysteriza/Linux-Mint-Scripts)

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

## 5. TOR Switch  
<img src="https://github.com/user-attachments/assets/cd8baccf-7e24-48b7-b633-68d5a228bc29" width="450"/>

This utility manages the TOR service from a friendly GUI:

- Displays whether TOR is currently active or inactive
- Lets you start or stop the service via `pkexec`

Useful for toggling TOR service as needed without using the terminal.

---

## 6. Shortcut Maker
<img src="https://github.com/user-attachments/assets/07de9b81-44b8-4873-9498-1ccb0e85af07" width="450"/>

A simple interactive tool to create custom application shortcuts via GUI:

- Select the executable file
- Enter the shortcut name, comment, and icon
- Choose the desired category
- Automatically creates a `.desktop` launcher

This tool eliminates the need to manually edit `.desktop` files or rely on terminal commands, making it perfect for quickly organizing and launching your scripts or apps from the Linux Mint menu.

---

## 7. Proxy Tester
<img src="https://github.com/user-attachments/assets/82f860f7-5c10-4e6e-92fe-933694453b02" width="450"/>

This script tests SOCKS5 proxies listed in `/etc/proxychains4.conf`:

- Checks if each proxy is **active** or **dead**
- Fetches geolocation (country, city, ISP) using `ip-api.com`
- Measures latency to identify the fastest proxy
- Displays results in a clean, colored, line-based format

Perfect for verifying proxy performance and reliability for privacy-focused tasks. Requires `proxychains4` and `jq` for JSON parsing.

---

## Requirements

Ensure the following packages are installed:

- `zenity` — for displaying GUI dialogs (used in some scripts)
- `cpufrequtils` — for setting CPU governor
- `pkexec` — to perform actions with elevated privileges (usually provided by `policykit-1`)
- `proxychains4` — for proxy testing (required for Proxy Tester)
- `jq` — for JSON parsing (required for Proxy Tester)

Install them via:

```bash
sudo apt install zenity cpufrequtils policykit-1 proxychains4 jq
```

## How to run
```bash
git clone https://github.com/Mysteriza/Linux-Mint-Scripts.git && cd Linux-Mint-Scripts
```
Make the script executable:
```bash
chmod +x ./script-name.sh
```
Replace `script-name.sh` with the actual script you want to run.

Run the script:
```bash
./script-name.sh
```
