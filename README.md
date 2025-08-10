# ShieldX - SafeDroid Antivirus

![ShieldX Logo](vx.png)  

**ShieldX** is an advanced antivirus and security scanner designed for Linux and Android (Termux) environments.

---

## Features

- Simple login system (username: `@admin`, password: `@admin`)
- Smart and fast scanning of suspicious and large files in user directories
- Comprehensive Android APK analysis:
  - APK decompilation using apktool
  - Extraction of app permissions
  - Detection of suspicious IP addresses within the payload
  - Identification of suspicious filenames (e.g. backdoor, virus, hack)
  - Organized results saved in dedicated folders with detailed reports
  - Option to delete suspicious files upon user confirmation
- Cache clearing to free up space and improve performance
- System monitoring showing top CPU-consuming processes
- Interactive, colorful interface with hacker-style green and purple theme
- Intelligent alerts for suspicious files during scans
- Simple auto-update check from GitHub
- Creation of timestamped folders for each scan, storing all files and logs
- No root required, only necessary permissions requested

---

## Requirements

- Linux or Termux on Android
- [apktool](https://ibotpeaches.github.io/Apktool/) for APK analysis
- Bash shell (pre-installed on most Linux distributions)
- Internet connection for update checks

---

## Installation and Usage

1. Download the script `ShieldX.sh` from the repository.
2. Make it executable:

   ```bash
   chmod +x ShieldX.sh
