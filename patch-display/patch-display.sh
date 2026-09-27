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

echo -e "[*] Fixing touchscreen to match the display orientation..."
echo -e "${GREEN}[+] Creating touchscreen fix script...${NC}"
SCRIPT_PATH="/etc/lightdm/fix-touchscreen.sh"
if [ ! -f "$SCRIPT_PATH" ]; then
    cat << 'EOF' > "$SCRIPT_PATH"
#!/bin/bash
# Tell xinput which display server connection to target
export DISPLAY=:0
export XAUTHORITY=/var/run/lightdm/root/:0

# Apply exact working touch mapping command
xinput map-to-output "FTSC1000:00 2808:1015" DSI-1
EOF

    chmod +x "$SCRIPT_PATH"
    echo -e "${GREEN}[+] Created and made executable: $SCRIPT_PATH${NC}"
else
    echo -e "${YELLOW}[!] $SCRIPT_PATH already exists.${NC}"
fi

echo -e "${GREEN}[+] Updating LightDM configuration...${NC}"
LIGHTDM_CONF="/etc/lightdm/lightdm.conf"

if [ ! -f "$LIGHTDM_CONF" ]; then
    echo -e "[Seat:*]\ndisplay-setup-script=$SCRIPT_PATH" > "$LIGHTDM_CONF"
    echo -e "${GREEN}[+] Created lightdm.conf and added display-setup-script.${NC}"
else
    if grep -q "display-setup-script" "$LIGHTDM_CONF"; then
        echo -e "${YELLOW}[!] display-setup-script is already configured in lightdm.conf.${NC}"
    else
        if grep -q "\[Seat:\*\]" "$LIGHTDM_CONF"; then
            sed -i "/\[Seat:\*\]/a display-setup-script=$SCRIPT_PATH" "$LIGHTDM_CONF"
        else
            echo -e "\n[Seat:*]\ndisplay-setup-script=$SCRIPT_PATH" >> "$LIGHTDM_CONF"
        fi
        echo -e "${GREEN}[+] Added display-setup-script to lightdm.conf under [Seat:*].${NC}"
    fi
fi

echo -e "Done!"