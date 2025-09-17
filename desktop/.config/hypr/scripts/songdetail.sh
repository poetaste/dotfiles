#!/bin/bash

song_info=$(playerctl metadata --format '{{title}}   {{artist}}' 2>/dev/null)

if [ -z "$song_info" ]; then
  echo "No music playing"
else
  echo "$song_info"
fi
