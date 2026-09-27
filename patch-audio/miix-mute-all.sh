#!/bin/bash

# Wait up to 20 seconds for the bytcr-rt5640 sound card to initialize
TIMEOUT=20
CARD_NUM=""

while [ $TIMEOUT -gt 0 ]; do
  if [ -f /proc/asound/cards ]; then
    CARD_NUM=$(grep -i "bytcr-rt5640" /proc/asound/cards 2>/dev/null | grep -o '^[ 0-9]*' | tr -d ' ')
    if [ -n "$CARD_NUM" ]; then
      break
    fi
  fi
  sleep 1
  TIMEOUT=$((TIMEOUT - 1))
done

if [ -z "$CARD_NUM" ]; then
  CARD_NUM=1
fi

# 1. Mute all outputs completely
amixer -c "$CARD_NUM" -q cset iface=MIXER,name='Speaker Playback Switch' off 2>/dev/null || true
amixer -c "$CARD_NUM" -q cset iface=MIXER,name='Speaker Output Switch' off 2>/dev/null || true
amixer -c "$CARD_NUM" -q cset iface=MIXER,name='Headphone Playback Switch' off 2>/dev/null || true
amixer -c "$CARD_NUM" -q cset iface=MIXER,name='Headphone Output Switch' off 2>/dev/null || true

# 2. Mute all inputs and ADCs to prevent feedback loops
amixer -c "$CARD_NUM" -q cset iface=MIXER,name='Internal Mic Switch' off 2>/dev/null || true
amixer -c "$CARD_NUM" -q cset iface=MIXER,name='Headset Mic Switch' off 2>/dev/null || true
amixer -c "$CARD_NUM" -q cset iface=MIXER,name='Mono ADC Capture Switch' off 2>/dev/null || true
amixer -c "$CARD_NUM" -q cset iface=MIXER,name='ADC Capture Switch' off 2>/dev/null || true

# 3. Set a safe default speaker volume (25%)
amixer -c "$CARD_NUM" -q cset iface=MIXER,name='Speaker Playback Volume' 25% 2>/dev/null || true