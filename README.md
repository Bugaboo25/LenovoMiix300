# \# Debian 13 with Xfce on Lenovo Miix 300

# 

# A comprehensive guide to creating a bootable USB installer, installing Debian 13 with Xfce, applying hardware patches for the Lenovo Miix 300 tablet, and understanding known limitations.

# 

# \## Prerequisites \& USB Creation

# 

# Because the Lenovo Miix 300 is a 32-bit UEFI device running on a 64-bit processor, standard Debian installers require a small manual tweak to boot properly.

# 

# 1\. Download and install \*\*Rufus\*\* on a Windows computer.

# 2\. Select your \*\*Debian 13\*\* ISO image.

# 3\. Set the \*\*Partition scheme\*\* to `GPT`.

# 4\. Press \*\*Start\*\* to create the bootable USB key.

# 5\. \*\*Crucial 32-bit UEFI Fix:\*\* After the USB key is created, navigate to the `/boot` folder on the USB drive, find `bootia32.efi`, and copy it into the `EFI/boot` directory so the tablet's BIOS can recognize it.

# 

# !\[Rufus Configuration Screenshot](docs/rufus.png)

# 

# \## Installation on Lenovo Miix 300

# 

# 1\. Turn on the tablet and press \*\*F12\*\* repeatedly to enter the BIOS settings.

# 2\. Make sure that \*\*Secure Boot\*\* is \*\*disabled\*\*.

# 3\. Insert your prepared USB boot key.

# 4\. If the bootloader does not automatically appear, restart and press \*\*F2\*\* repeatedly to select the boot device.

# 5\. Proceed with the Debian installation and choose \*\*Xfce\*\* as your window manager for optimal performance on this low-resource hardware.

# 

# \## Post-Install Patching

# 

# The Lenovo Miix 300 (Intel Atom / Bay Trail architecture) requires specific firmware and configuration adjustments for full hardware functionality (such as audio, touchscreen, and power management).

# 

# 1\. Open a terminal using `Ctrl + Alt + T`.

# 2\. If your user account is not already in the `sudoers` list, grant yourself permissions by running:

# 

# &#x20;  ```bash

# &#x20;  su -

# &#x20;  usermod -aG sudo <username>

# &#x20;  sudo reboot

# &#x20;  ```

# 

# 3\. After rebooting, clone the dedicated hardware support repository and run the setup script:

# 

# &#x20;  ```bash

# &#x20;  git clone https://github.com/Bugaboo25/LenovoMiix300.git

# &#x20;  cd LenovoMiix300

# &#x20;  chmod +x setup.sh

# &#x20;  sudo ./setup.sh

# &#x20;  sudo reboot

# &#x20;  ```

# 

# \## Known Issues

# 

# While core system functions operate well after running the setup script, please note the following limitations:

# \- \*\*Cameras:\*\* Both the front and back cameras do not work due to missing Linux driver support for the Intel ISP camera sensors.

# \- \*\*Sensors / Touch:\*\* Minor configuration adjustments may occasionally be needed for screen auto-rotation or touch calibration.

# 

# Enjoy your fully functional Debian setup on the Lenovo Miix 300!

