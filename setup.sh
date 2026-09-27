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

echo -e "${CYAN}[*] Updating package lists...${NC}"
apt update

echo -e "${CYAN}[*] Starting system patching sequence...${NC}"

# 1. Run Audio Patch Script
AUDIO_SCRIPT="patch-audio/patch-audio.sh"
if [ -f "$AUDIO_SCRIPT" ]; then
  echo -e "${CYAN}[*] Executing audio patch script...${NC}"
  # Make main script and any companion .sh scripts in the folder executable
  chmod +x "$AUDIO_SCRIPT"
  [ -f "patch-audio/miix-boot-mute.sh" ] && chmod +x "patch-audio/miix-boot-mute.sh"
  
  bash "$AUDIO_SCRIPT"
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}[+] Audio patch completed successfully.${NC}"
  else
    echo -e "${RED}[-] Audio patch script encountered an error.${NC}"
  fi
else
  echo -e "${YELLOW}[!] Audio patch script not found at '$AUDIO_SCRIPT'. Skipping audio setup.${NC}"
fi

# 2. Run Display Patch Script
DISPLAY_SCRIPT="patch-display/patch-display.sh"
if [ -f "$DISPLAY_SCRIPT" ]; then
  echo -e "${CYAN}[*] Executing display patch script...${NC}"
  # Make main display script and any companion .sh scripts in the folder executable
  chmod +x "$DISPLAY_SCRIPT"
  find patch-display/ -name "*.sh" -exec chmod +x {} +
  
  bash "$DISPLAY_SCRIPT"
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}[+] Display patch completed successfully.${NC}"
  else
    echo -e "${RED}[-] Display patch script encountered an error.${NC}"
  fi
else
  echo -e "${YELLOW}[!] Display patch script not found at '$DISPLAY_SCRIPT'. Skipping display setup.${NC}"
fi

# Completion Banner
echo -e "${GREEN}"
echo "================================================================="
echo "       LENOVO MIIX 300 SETUP & CONFIGURATION COMPLETE!           "
echo "================================================================="
echo -e "${NC}"
echo -e "${YELLOW}Please reboot your system now to apply all changes.${NC}"