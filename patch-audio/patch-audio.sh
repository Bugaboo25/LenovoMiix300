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

echo -e "${CYAN}[*] Muting the bytcr-rt5640 sound card...${NC}"

CARD_NUM=1

# 1. Mute all outputs completely
amixer -c "$CARD_NUM" -q cset iface=MIXER,name='Speaker Playback Switch' off || true
amixer -c "$CARD_NUM" -q cset iface=MIXER,name='Speaker Output Switch' off || true
amixer -c "$CARD_NUM" -q cset iface=MIXER,name='Headphone Playback Switch' off || true
amixer -c "$CARD_NUM" -q cset iface=MIXER,name='Headphone Output Switch' off || true

# 2. Mute all inputs and ADCs to prevent feedback loops
amixer -c "$CARD_NUM" -q cset iface=MIXER,name='Internal Mic Switch' off || true
amixer -c "$CARD_NUM" -q cset iface=MIXER,name='Headset Mic Switch' off || true
amixer -c "$CARD_NUM" -q cset iface=MIXER,name='Mono ADC Capture Switch' off || true
amixer -c "$CARD_NUM" -q cset iface=MIXER,name='ADC Capture Switch' off || true

# 3. Set a safe default speaker volume (25%)
amixer -c "$CARD_NUM" -q cset iface=MIXER,name='Speaker Playback Volume' 25% || true

# Store default ALSA state
alsactl store || true
echo -e "${GREEN}[+] ALSA state stored successfully.${NC}"

echo -e "${CYAN}[*] Done!${NC}"