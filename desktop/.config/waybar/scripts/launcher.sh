#!/bin/bash

# Hide waybar
pkill -SIGUSR1 waybar

# Launch nwg-drawer asynchronously and restore waybar when it exits
nwg-drawer &
drawer_pid=$!

# When nwg-drawer quits, restore waybar
wait $drawer_pid
pkill -SIGUSR1 waybar
