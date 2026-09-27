#!/bin/bash

# Wait up to 20 seconds for the bytcr-rt5640 sound card to initialize
TIMEOUT=20
CARD_NUM=""

while [ $TIMEOUT -gt 0 ]; do
  if [ -f /proc/asound/cards ]; then
    # Find the exact card index associated with bytcr-rt5640
    CARD_NUM=$(grep -i "bytcr-rt5640" /proc/asound/cards 2>/dev/null | grep -o '^[ 0-9]*' | tr -d ' ')
    if [ -n "$CARD_NUM" ]; then
      break
    fi
  fi
  sleep 1
  TIMEOUT=$((TIMEOUT - 1))
done

# Fallback to card 1 if dynamic detection fails
if [ -z "$CARD_NUM" ]; then
  CARD_NUM=1
fi

# Apply mutes safely to the correct sound card
amixer -c "$CARD_NUM" cset iface=MIXER,name='Speaker Switch' off 2>/dev/null || true
amixer -c "$CARD_NUM" cset iface=MIXER,name='Internal Mic Switch' off 2>/dev/null || true
amixer -c "$CARD_NUM" cset iface=MIXER,name='Headset Mic Switch' off 2>/dev/null || true
amixer -c "$CARD_NUM" cset iface=MIXER,name='Headphone Switch' off 2>/dev/null || true