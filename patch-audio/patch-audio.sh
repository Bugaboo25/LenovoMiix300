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

echo -e "${CYAN}[*] Configuring pre-login systemd boot mute service...${NC}"

# Get the directory where patch-audio.sh is located
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
SRC_MUTING_SCRIPT="$SCRIPT_DIR/miix-boot-mute.sh"
DEST_MUTING_SCRIPT="/usr/local/bin/miix-boot-mute.sh"

SRC_SERVICE_FILE="$SCRIPT_DIR/miix-boot-mute.service"
DEST_SERVICE_FILE="/etc/systemd/system/miix-boot-mute.service"

# 1. Check if miix-boot-mute.sh is alongside this script, copy it, and make it executable
if [ -f "$SRC_MUTING_SCRIPT" ]; then
  cp "$SRC_MUTING_SCRIPT" "$DEST_MUTING_SCRIPT"
  chmod +x "$DEST_MUTING_SCRIPT"
  echo -e "${GREEN}[+] Successfully installed boot mute script to $DEST_MUTING_SCRIPT${NC}"
else
  echo -e "${RED}[-] miix-boot-mute.sh not found alongside patch-audio.sh!${NC}"
  exit 1
fi

# 2. Check if miix-boot-mute.service is alongside this script and copy it
if [ -f "$SRC_SERVICE_FILE" ]; then
  cp "$SRC_SERVICE_FILE" "$DEST_SERVICE_FILE"
  echo -e "${GREEN}[+] Successfully installed systemd service file to $DEST_SERVICE_FILE${NC}"
else
  echo -e "${RED}[-] miix-boot-mute.service not found alongside patch-audio.sh!${NC}"
  exit 1
fi

# 3. Reload daemon and enable the service
systemctl daemon-reload
systemctl enable miix-boot-mute.service

if [ $? -eq 0 ]; then
  echo -e "${GREEN}[+] Successfully enabled pre-login boot-mute service.${NC}"
else
  echo -e "${RED}[-] Failed to enable systemd service.${NC}"
fi

# 4. Apply mutes right now and save them into ALSA's default state
echo -e "${CYAN}[*] Applying initial mutes and storing default ALSA state...${NC}"
"$DEST_MUTING_SCRIPT"
alsactl store 2>/dev/null || true
echo -e "${GREEN}[+] ALSA state stored successfully.${NC}"

echo -e "${CYAN}[*] Done!${NC}"