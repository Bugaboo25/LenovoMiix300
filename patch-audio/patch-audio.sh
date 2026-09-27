#!/bin/bash

# ANSI color codes for formatting
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# Check if the script is run with root / sudo privileges
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[-] This script must be run with root privileges (using sudo).${NC}"
  exit 1
fi

echo -e "${CYAN}[*] Installing missing Intel sound firmware packages...${NC}"
apt install -y firmware-intel-sound firmware-misc-nonfree

echo -e "${CYAN}[*] Configuring UCM2 audio profile defaults (disabling startup noise & setting 25% volume)...${NC}"

# Locate the UCM2 HiFi.conf file for bytcr-rt5640
UCM_FILE="/usr/share/alsa/ucm2/Intel/bytcr-rt5640/HiFi.conf"
if [ ! -f "$UCM_FILE" ]; then
  UCM_FILE=$(find /usr/share/alsa/ucm2 -path "*bytcr-rt5640*"/HiFi.conf 2>/dev/null | head -n 1)
fi

if [ -z "$UCM_FILE" ] || [ ! -f "$UCM_FILE" ]; then
  echo -e "${RED}[-] Could not find bytcr-rt5640 HiFi.conf under /usr/share/alsa/ucm2/. Skipping UCM patch.${NC}"
else
  echo -e "${GREEN}[+] Found UCM2 file at: $UCM_FILE${NC}"
  
  # Check if already fully configured
  if grep -q "Speaker Playback Volume" "$UCM_FILE" && grep -q 'cset "name='\''Speaker Switch'\'' off"' "$UCM_FILE"; then
    echo -e "${YELLOW}[!] The UCM2 file is already configured with disabled defaults and 25% volume!${NC}"
  else
    echo -e "${CYAN}[*] Creating backup as HiFi.conf.bak...${NC}"
    cp "$UCM_FILE" "${UCM_FILE}.bak"

    # Locate patch_ucm.py in the same directory as this script
    PYTHON_SCRIPT="$(dirname "$0")/patch-ucm2.py"
    if [ ! -f "$PYTHON_SCRIPT" ]; then
      echo -e "${RED}[-] Error: patch-ucm2.py could not be found in the same directory!${NC}"
      exit 1
    fi

    # Run the separate Python script with sudo privileges
    python3 "$PYTHON_SCRIPT" "$UCM_FILE"

    if [ $? -eq 0 ]; then
      echo -e "${GREEN}[+] UCM2 configuration successfully applied!${NC}"
    else
      echo -e "${RED}[-] UCM2 modification failed. Original file remains safe (backup at HiFi.conf.bak).${NC}"
    fi
  fi
fi

echo -e "${CYAN}[*] Done!${NC}"