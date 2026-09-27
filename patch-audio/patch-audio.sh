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

echo -e "${CYAN}[*] Configuring CPU C-state limits to prevent audio register corruption...${NC}"
if ! grep -q "intel_idle.max_cstate=1" /etc/default/grub; then
    sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 intel_idle.max_cstate=1"/' /etc/default/grub
    echo -e "${GREEN}[+] intel_idle.max_cstate=1 parameter added to GRUB successfully!${NC}"
    update-grub
else
    echo -e "${YELLOW}[!] intel_idle.max_cstate=1 is already present in GRUB configuration.${NC}"
fi

# Get the directory where patch-audio.sh is located
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
MUTING_SCRIPT="$SCRIPT_DIR/miix-mute-all.sh"

# Chmod and run miix-mute-all, then store the ALSA state
if [ -f "$MUTING_SCRIPT" ]; then
  chmod +x "$MUTING_SCRIPT"
  echo -e "${CYAN}[*] Executing miix-mute-all and storing default ALSA state...${NC}"
  "$MUTING_SCRIPT"
  alsactl store 2>/dev/null || true
  echo -e "${GREEN}[+] ALSA state stored successfully.${NC}"
else
  echo -e "${RED}[-] miix-mute-all not found alongside patch-audio.sh!${NC}"
  exit 1
fi

echo -e "${CYAN}[*] Done!${NC}"