#!/bin/bash
# Target card 1 (bytcr-rt5640) and mute everything at boot to prevent feedback/pop
amixer -c 1 cset iface=MIXER,name='Speaker Switch' off 2>/dev/null
amixer -c 1 cset iface=MIXER,name='Internal Mic Switch' off 2>/dev/null
amixer -c 1 cset iface=MIXER,name='Headset Mic Switch' off 2>/dev/null
amixer -c 1 cset iface=MIXER,name='Headphone Switch' off 2>/dev/null