#!/bin/bash
export DISPLAY=:0
export XAUTHORITY=/var/run/lightdm/root/:0

# Start the python daemon in the background and detach it
/usr/bin/python3 /etc/lightdm/miix-rotate-daemon.py &