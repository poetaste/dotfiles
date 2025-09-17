#!/bin/bash

# Exit early if bluetoothctl not found
command -v bluetoothctl >/dev/null 2>&1 || {
  echo "No bt"
  exit 0
}

# Check if Bluetooth is powered on
if ! bluetoothctl show | grep -q "Powered: yes"; then
  echo " Off"
  exit 0
fi

# Get connected devices
connected_devices=$(bluetoothctl devices Connected | grep "^Device ")

if [ -z "$connected_devices" ]; then
  echo " No devices"
  exit 0
fi

# Arrays
audio=()
controllers=()
mice=()
other=()

# Parse devices
while IFS= read -r line; do
  mac=$(echo "$line" | cut -d ' ' -f2)
  name=$(echo "$line" | cut -d ' ' -f3-)
  info=$(bluetoothctl info "$mac" 2>/dev/null)

  if echo "$info" | grep -qi "Audio\|Headset\|A2DP"; then
    audio+=("$name")
  elif echo "$name" | grep -qi "controller\|gamepad\|xbox\|ps\|nintendo"; then
    controllers+=("$name")
  elif echo "$name" | grep -qi "mouse\|trackball" || echo "$info" | grep -qi "mouse"; then
    mice+=("$name")
  else
    other+=("$name")
  fi
done <<<"$connected_devices"

# Pick display
if [ ${#audio[@]} -gt 0 ]; then
  echo " ${audio[0]}"
elif [ ${#controllers[@]} -gt 0 ]; then
  echo "🎮 ${controllers[0]}"
elif [ ${#mice[@]} -gt 0 ]; then
  echo "🖱 ${mice[0]}"
else
  echo " ${other[0]}"
fi
