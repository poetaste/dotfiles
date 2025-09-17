#!/bin/bash

# Your wallpaper directory
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/"

# Transition settings
TRANSITION_TYPE="grow"        # Choose a smoother effect
DURATION="2.5"                # Increase duration for smoother transition
export SWWW_TRANSITION_FPS=60 # Set transition FPS for smoother animations

# Pick a random wallpaper from the folder
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | shuf -n 1)

# Start swww daemon if not already running
pgrep -x swww-daemon >/dev/null || swww init

# Set wallpaper with transition
swww img "$WALLPAPER" --transition-type "$TRANSITION_TYPE" --transition-duration "$DURATION"
