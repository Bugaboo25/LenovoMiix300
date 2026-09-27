#!/bin/bash

# ANSI color codes for formatting
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if the script is run with root / sudo privileges
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[-] This script must be run with root privileges (using sudo).${NC}"
  exit 1
fi

echo -e "${GREEN}[+] Updating package lists...${NC}"
apt update

echo -e "${GREEN}[+] Installing missing Intel sound firmware packages...${NC}"
apt install -y firmware-intel-sound firmware-misc-nonfree

echo -e "\n${GREEN}[+] Audio patch complete!${NC}"