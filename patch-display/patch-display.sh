#!/bin/bash

# ANSI color codes for formatting
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Ensure the script is run with root/sudo privileges
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[-] This script must be run with root privileges (using sudo).${NC}"
    exit 1
fi

echo -e "[*] Installing required packages..."
echo -e "${GREEN}[+] Installing iio-sensor-proxy...${NC}"
apt-get install -y iio-sensor-proxy

echo -e "[*] Configuring Display Orientation (Landscape)"
echo -e "${GREEN}[+] Updating GRUB configuration...${NC}"
if ! grep -q "fbcon=rotate:1" /etc/default/grub; then
    sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 fbcon=rotate:1"/' /etc/default/grub
    echo -e "${GREEN}[+] GRUB parameter added successfully!${NC}"
    update-grub
else
    echo -e "${YELLOW}[!] fbcon=rotate:1 is already present in GRUB configuration.${NC}"
fi

echo -e "[*] Fixing SoC PWM Chip & Backlight Control"
echo -e "${GREEN}[+] Configuring initramfs for PWM modules...${NC}"
INITRAMFS_MODULES="/etc/initramfs-tools/modules"
PWM_MODS=("pwm_lpss" "pwm_lpss_platform")
INITRAMFS_UPDATE_NEEDED=false

for mod in "${PWM_MODS[@]}"; do
    if ! grep -q "^$mod" "$INITRAMFS_MODULES"; then
        echo "$mod" >> "$INITRAMFS_MODULES"
        INITRAMFS_UPDATE_NEEDED=true
        echo -e "${GREEN}[+] Added $mod to $INITRAMFS_MODULES${NC}"
    else
        echo -e "${YELLOW}[!] $mod is already present in $INITRAMFS_MODULES.${NC}"
    fi
done

if [ "$INITRAMFS_UPDATE_NEEDED" = true ]; then
    echo -e "${GREEN}[+] Updating initial ramdisk (initramfs)...${NC}"
    update-initramfs -u
    echo -e "${GREEN}[+] Initramfs updated successfully!${NC}"
else
    echo -e "${YELLOW}[!] PWM modules already configured in initramfs; skipping update.${NC}"
fi

echo -e "[*] Setting up rotation daemon and touchscreen launcher..."
# Get the directory where this patch script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SRC_FIX="$SCRIPT_DIR/fix-touchscreen.sh"
SRC_DAEMON="$SCRIPT_DIR/miix-rotate-daemon.py"

DEST_FIX="/etc/lightdm/fix-touchscreen.sh"
DEST_DAEMON="/etc/lightdm/miix-rotate-daemon.py"

if [ -f "$SRC_FIX" ] && [ -f "$SRC_DAEMON" ]; then
    cp "$SRC_FIX" "$DEST_FIX"
    cp "$SRC_DAEMON" "$DEST_DAEMON"
    chmod +x "$DEST_FIX"
    chmod +x "$DEST_DAEMON"
    echo -e "${GREEN}[+] Successfully copied fix-touchscreen.sh and miix-rotate-daemon.py to /etc/lightdm/${NC}"
else
    echo -e "${RED}[-] Error: Missing fix-touchscreen.sh or miix-rotate-daemon.py in the script's directory!${NC}"
    exit 1
fi

echo -e "${GREEN}[+] Updating LightDM configuration...${NC}"
LIGHTDM_CONF="/etc/lightdm/lightdm.conf"

if [ ! -f "$LIGHTDM_CONF" ]; then
    echo -e "[Seat:*]\ndisplay-setup-script=$DEST_FIX" > "$LIGHTDM_CONF"
    echo -e "${GREEN}[+] Created lightdm.conf and added display-setup-script.${NC}"
else
    # Check specifically for an ACTIVE (uncommented) line starting with display-setup-script
    if grep -qE '^[[:space:]]*display-setup-script' "$LIGHTDM_CONF"; then
        echo -e "${YELLOW}[!] display-setup-script is already actively configured in lightdm.conf.${NC}"
    else
        if grep -q "\[Seat:\*\]" "$LIGHTDM_CONF"; then
            sed -i "/\[Seat:\*\]/a display-setup-script=$DEST_FIX" "$LIGHTDM_CONF"
        else
            echo -e "\n[Seat:*]\ndisplay-setup-script=$DEST_FIX" >> "$LIGHTDM_CONF"
        fi
        echo -e "${GREEN}[+] Added display-setup-script to lightdm.conf under [Seat:*].${NC}"
    fi
fi

echo -e "Done!"