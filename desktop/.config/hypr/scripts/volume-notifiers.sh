#!/bin/bash

ICON_VOL=""  # nf-fa-volume_up
ICON_LOW=""  # nf-fa-volume_down
ICON_MUTE="" # nf-fa-volume_off

case $1 in
up)
  pactl set-sink-volume @DEFAULT_SINK@ +5%
  ;;
down)
  pactl set-sink-volume @DEFAULT_SINK@ -5%
  ;;
mute)
  pactl set-sink-mute @DEFAULT_SINK@ toggle
  ;;
esac

VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | awk 'NR==1{print $5}' | tr -d '%')
MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

if [ "$MUTE" = "yes" ]; then
  ICON="$ICON_MUTE"
  MSG="Muted"
  VOL=0
else
  if [ "$VOL" -ge 70 ]; then
    ICON="$ICON_VOL"
  elif [ "$VOL" -ge 30 ]; then
    ICON="$ICON_LOW"
  else
    ICON="$ICON_MUTE"
  fi
  MSG="$VOL%"
fi

notify-send -r 9999 -h string:x-canonical-private-synchronous:volume -h int:value:"$VOL" "$ICON  $MSG"
