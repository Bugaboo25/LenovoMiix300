#!/usr/bin/env python3
import os
import time
import subprocess

# Force the script to target the main X11 display
os.environ['DISPLAY'] = ':0'

IIO_PATH = "/sys/bus/iio/devices/iio:device0"
TOUCHSCREEN_NAME = "FTSC1000:00 2808:1015"
TILT_THRESHOLD = 150  # Acceleration threshold for triggering rotation

# Offset rotation mapping: shifts everything 90 degrees right to match panel mounting
ROTATION_MAP = {
    "normal": "right",
    "right": "normal",
    "inverted": "left",
    "left": "inverted"
}

def get_display():
    try:
        out = subprocess.check_output(['xrandr'], universal_newlines=True)
        for line in out.splitlines():
            if ' connected' in line:
                return line.split()[0]
    except Exception:
        pass
    return "eDP-1"

def read_axis(axis):
    try:
        with open(os.path.join(IIO_PATH, f"in_accel_{axis}_raw"), "r") as f:
            return float(f.read().strip())
    except Exception:
        return 0.0

def main():
    display = get_display()
    current_rotation = None
    print(f"Starting direct rotation daemon for display: {display}")

    while True:
        x = read_axis('x')
        y = read_axis('y')

        # Determine base orientation from accelerometer
        if abs(y) >= abs(x):
            if y > TILT_THRESHOLD:
                base_rotation = "normal"
            elif y < -TILT_THRESHOLD:
                base_rotation = "inverted"
            else:
                base_rotation = current_rotation
        else:
            if x > TILT_THRESHOLD:
                base_rotation = "right"
            elif x < -TILT_THRESHOLD:
                base_rotation = "left"
            else:
                base_rotation = current_rotation

        # Apply the 90-degree right offset
        if base_rotation:
            new_rotation = ROTATION_MAP.get(base_rotation, "normal")
        else:
            new_rotation = current_rotation

        if new_rotation and new_rotation != current_rotation:
            current_rotation = new_rotation
            # Rotate screen
            subprocess.run(['xrandr', '--output', display, '--rotate', current_rotation])
            # Re-map touchscreen matrix to match the new display orientation
            subprocess.run(['xinput', 'map-to-output', TOUCHSCREEN_NAME, display])

        time.sleep(0.8)

if __name__ == "__main__":
    main()