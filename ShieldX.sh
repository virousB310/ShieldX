#!/bin/bash

USERS_FILE=".users.txt"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

logo() {
  echo -e "${BLUE}"
  echo "  _____       __        ____              _     _ "
  echo " / ___/____ _/ /_____  / __ \____ _____  (_)___(_)___ "
  echo " \__ \/ __ \`/ __/ __ \/ /_/ / __ \`/ __ \/ / __/ / __ \\"
  echo "___/ / /_/ / /_/ /_/ / ____/ /_/ / / / / / /_/ / /_/ /"
  echo "/____/\__,_/\__/\____/_/    \__,_/_/ /_/_/\__/_/ .___/"
  echo "                                              /_/     "
  echo -e "${NC}"
  echo "by: virous_b310"
}

register() {
  echo -e "${YELLOW}=== Register ===${NC}"
  read -p "Enter new username: " user
  read -sp "Enter new password: " pass
  echo
  echo "$user:$pass" >> "$USERS_FILE"
  echo -e "${GREEN}[+] User registered successfully.${NC}"
}

login() {
  echo -e "${YELLOW}=== Login ===${NC}"
  read -p "Username: " user
  read -sp "Password: " pass
  echo
  if grep -q "$user:$pass" "$USERS_FILE"; then
    echo -e "${GREEN}[+] Login successful!${NC}"
    main_menu
  else
    echo -e "${RED}[-] Invalid login!${NC}"
  fi
}

main_menu() {
  while true; do
    echo
    echo -e "${BLUE}==== SafeDroid Antivirus Menu ====${NC}"
    echo -e "${YELLOW}1.${NC} Scan for .exe files"
    echo -e "${YELLOW}2.${NC} Scan for large files (>100MB)"
    echo -e "${YELLOW}3.${NC} Scan for .sh files"
    echo -e "${YELLOW}4.${NC} Scan for suspicious file names"
    echo -e "${YELLOW}5.${NC} Scan home directory"
    echo -e "${YELLOW}6.${NC} Full storage scan"
    echo -e "${YELLOW}7.${NC} Show running processes"
    echo -e "${YELLOW}8.${NC} Scan for writable files"
    echo -e "${YELLOW}9.${NC} Scan for hidden files"
    echo -e "${YELLOW}10.${NC} Scan for duplicate files"
    echo -e "${YELLOW}11.${NC} Delete temp/cache files"
    echo -e "${YELLOW}12.${NC} Custom path scan"
    echo -e "${YELLOW}13.${NC} Exit"
    echo
    read -p "Choose option: " choice

    case $choice in
      1) find ~ -name "*.exe" ;;
      2) find ~ -type f -size +100M ;;
      3) find ~ -name "*.sh" ;;
      4) find ~ -regex '.*virus\|hack\|backdoor.*' ;;
      5) find ~ ;;
      6) find /storage ;;
      7) ps aux ;;
      8) find ~ -perm -222 ;;
      9) find ~ -name ".*" ;;
      10) command -v fdupes >/dev/null && fdupes ~ || echo -e "${RED}fdupes not installed${NC}" ;;
      11) rm -rf ~/.cache/* /data/data/com.termux/cache/* && echo -e "${GREEN}[+] Cache cleared${NC}" ;;
      12) read -p "Enter path: " path; find "$path" ;;
      13) echo -e "${GREEN}Exiting...${NC}"; exit ;;
      *) echo -e "${RED}Invalid option${NC}" ;;
    esac
  done
}

# Main start
clear
logo
echo -e "${BLUE}Welcome to SafeDroid Antivirus${NC}"
echo -e "${YELLOW}1.${NC} Register"
echo -e "${YELLOW}2.${NC} Login"
read -p "Choose: " action

case $action in
  1) register ;;
  2) login ;;
  *) echo -e "${RED}Invalid option${NC}" ;;
esac
