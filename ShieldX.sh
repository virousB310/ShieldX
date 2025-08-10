#!/bin/bash

# -------- ألوان --------
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

MAX_LOGIN_ATTEMPTS=3
SCAN_DIR="./ScanResults"
APKTOOL_BIN=$(command -v apktool)

# -------- شعار --------
logo() {
  clear
  echo -e "${PURPLE}"
  echo "      .---."
  echo "     /     \\"
  echo "    | -.- |   Hacker Shield X"
  echo "    \\  ^  /   Protecting You!"
  echo "     '---'  "
  echo -e "${NC}"
}

# -------- تسجيل الدخول --------
login() {
  local attempts=0
  while (( attempts < MAX_LOGIN_ATTEMPTS )); do
    echo -e "${YELLOW}=== Login ===${NC}"
    read -p "Username (must be @admin): " user
    read -sp "Password (must be @admin): " pass
    echo
    if [[ "$user" == "@admin" && "$pass" == "@admin" ]]; then
      echo -e "${GREEN}[+] Login successful! Welcome, $user${NC}"
      return 0
    else
      echo -e "${RED}[-] Invalid credentials. Try again.${NC}"
      ((attempts++))
    fi
  done
  echo -e "${RED}Too many failed attempts. Exiting.${NC}"
  exit 1
}

# -------- تحذير --------
alert() {
  echo -e "${RED}[!] Warning: $1${NC}"
}

# -------- إنشاء مجلد نتائج --------
prepare_result_dir() {
  local scan_name="$1"
  local timestamp=$(date +%Y%m%d_%H%M%S)
  local dir="$SCAN_DIR/${scan_name}_$timestamp"
  mkdir -p "$dir"
  echo "$dir"
}

# -------- فحص ذكي --------
smart_scan() {
  echo -e "${CYAN}Starting Smart Scan...${NC}"
  local result_dir=$(prepare_result_dir "SmartScan")
  local suspicious_found=0

  local TARGET_DIRS=("$HOME/Downloads" "$HOME/Documents" "$HOME/Pictures")

  for dir_path in "${TARGET_DIRS[@]}"; do
    if [[ -d "$dir_path" ]]; then
      echo -e "${GREEN}Scanning $dir_path for large files...${NC}"
      find "$dir_path" -type f -size +50M >> "$result_dir/large_files.log"
      echo -e "${GREEN}Scanning $dir_path for suspicious files...${NC}"
      find "$dir_path" -type f \( -iname '*virus*' -o -iname '*hack*' -o -iname '*backdoor*' \) >> "$result_dir/suspicious_files.log"
    fi
  done

  if [[ -s "$result_dir/suspicious_files.log" ]]; then
    suspicious_found=1
    alert "Suspicious files detected! Check $result_dir/suspicious_files.log"
  else
    echo -e "${GREEN}No suspicious files found.${NC}"
  fi

  echo -e "${GREEN}Smart Scan complete. Results saved in $result_dir${NC}"
  read -p "Press Enter to continue..."
}

# -------- تنظيف الكاش --------
clear_cache() {
  echo -e "${CYAN}Clearing cache...${NC}"
  rm -rf ~/.cache/* /data/data/com.termux/cache/* 2>/dev/null
  echo -e "${GREEN}Cache cleared!${NC}"
  read -p "Press Enter to continue..."
}

# -------- مراقبة النظام --------
system_monitor() {
  echo -e "${CYAN}Top CPU-consuming processes:${NC}"
  ps aux --sort=-%cpu | head -n 15
  read -p "Press Enter to continue..."
}

# -------- تحليل APK --------
analyze_apk() {
  if [[ -z "$APKTOOL_BIN" ]]; then
    alert "apktool is not installed! Please install apktool to use this feature."
    read -p "Press Enter to continue..."
    return
  fi

  read -p "Enter full path to APK file: " apk_file
  if [[ ! -f "$apk_file" ]]; then
    alert "File not found!"
    read -p "Press Enter to continue..."
    return
  fi

  local result_dir=$(prepare_result_dir "APKAnalysis")
  echo -e "${CYAN}Decompiling APK...${NC}"
  apktool d -f "$apk_file" -o "$result_dir/decompiled" >/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    alert "Failed to decompile APK."
    rm -rf "$result_dir"
    read -p "Press Enter to continue..."
    return
  fi

  echo -e "${GREEN}APK Decompiled to $result_dir/decompiled${NC}"

  echo -e "${CYAN}Extracting permissions...${NC}"
  grep -oP '(?<=uses-permission android:name=")[^"]*' "$result_dir/decompiled/AndroidManifest.xml" > "$result_dir/permissions.log" || echo "No permissions found." > "$result_dir/permissions.log"
  cat "$result_dir/permissions.log"

  echo -e "${CYAN}Searching for IP addresses in APK...${NC}"
  grep -r -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' "$result_dir/decompiled" | sort -u > "$result_dir/ip_addresses.log"
  if [[ -s "$result_dir/ip_addresses.log" ]]; then
    cat "$result_dir/ip_addresses.log"
  else
    echo "No IP addresses found."
  fi

  echo -e "${CYAN}Checking suspicious filenames...${NC}"
  find "$result_dir/decompiled" -type f \( -iname '*backdoor*' -o -iname '*hack*' -o -iname '*virus*' \) > "$result_dir/suspicious_files.log"
  if [[ -s "$result_dir/suspicious_files.log" ]]; then
    cat "$result_dir/suspicious_files.log"
  else
    echo "No suspicious files found."
  fi

  # حفظ التقرير كامل في ملف نصي
  echo -e "\nPermissions:" >> "$result_dir/report.txt"
  cat "$result_dir/permissions.log" >> "$result_dir/report.txt"
  echo -e "\nIP Addresses:" >> "$result_dir/report.txt"
  cat "$result_dir/ip_addresses.log" >> "$result_dir/report.txt"
  echo -e "\nSuspicious Files:" >> "$result_dir/report.txt"
  cat "$result_dir/suspicious_files.log" >> "$result_dir/report.txt"

  echo -e "${GREEN}Analysis complete. Full report saved in $result_dir/report.txt${NC}"

  # سؤال المستخدم هل يريد حذف الملفات المشبوهة
  if [[ -s "$result_dir/suspicious_files.log" ]]; then
    read -p "Delete suspicious files found? (y/n): " del_choice
    if [[ "$del_choice" =~ ^[Yy]$ ]]; then
      while IFS= read -r file; do
        if [[ -f "$file" ]]; then
          rm -f "$file"
          echo "Deleted $file"
        fi
      done < "$result_dir/suspicious_files.log"
    fi
  fi

  read -p "Press Enter to continue..."
}

# -------- تحديث تلقائي (تحقق من ملف على GitHub) --------
check_update() {
  local current_version="1.0"
  local url="https://raw.githubusercontent.com/virous-b310/ShieldX/main/version.txt"
  echo -e "${CYAN}Checking for updates...${NC}"
  local latest_version=$(curl -s "$url")
  if [[ -z "$latest_version" ]]; then
    echo -e "${YELLOW}Could not check updates.${NC}"
    return
  fi

  if [[ "$latest_version" != "$current_version" ]]; then
    echo -e "${GREEN}Update available! Latest version: $latest_version${NC}"
    echo "Please visit https://github.com/virous-b310/ShieldX to download the latest version."
  else
    echo -e "${GREEN}You are using the latest version ($current_version).${NC}"
  fi
  read -p "Press Enter to continue..."
}

# -------- القائمة الرئيسية --------
main_menu() {
  while true; do
    clear
    logo
    echo -e "${GREEN}==== SafeDroid Antivirus Menu ====${NC}"
    echo -e "${PURPLE}1.${NC} Smart Scan (fast & focused)"
    echo -e "${PURPLE}2.${NC} Analyze APK (decompile + permissions + IPs)"
    echo -e "${PURPLE}3.${NC} Clear Cache"
    echo -e "${PURPLE}4.${NC} System Monitor (top CPU processes)"
    echo -e "${PURPLE}5.${NC} Check for Updates"
    echo -e "${PURPLE}6.${NC} Exit"
    echo
    read -p "Choose an option: " choice

    case $choice in
      1) smart_scan ;;
      2) analyze_apk ;;
      3) clear_cache ;;
      4) system_monitor ;;
      5) check_update ;;
      6) echo -e "${GREEN}Goodbye! Stay safe!${NC}"; exit 0 ;;
      *) echo -e "${RED}Invalid option.${NC}"; sleep 1 ;;
    esac
  done
}

# -------- تنفيذ البرنامج --------
logo
login
main_menu
