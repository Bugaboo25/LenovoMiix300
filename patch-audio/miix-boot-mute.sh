#!/bin/bash
# Target card 0 (bytcr-rt5640) and mute everything at boot to prevent feedback/pop
amixer -c 0 cset iface=MIXER,name='Speaker Switch' off 2>/dev/null
amixer -c 0 cset iface=MIXER,name='Internal Mic Switch' off 2>/dev/null
amixer -c 0 cset iface=MIXER,name='Headset Mic Switch' off 2>/dev/null
amixer -c 0 cset iface=MIXER,name='Headphone Switch' off 2>/dev/null