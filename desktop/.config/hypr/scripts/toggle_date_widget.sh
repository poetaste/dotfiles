#!/usr/bin/env bash
set -euo pipefail

WIDGET="date_window"

ensure_state() {
  local windows
  windows=$(hyprctl activeworkspace -j | jq '.windows')
  if [ "${windows:-1}" -eq 0 ]; then
    # Open only if not already open
    if ! eww list-windows | grep -q "^${WIDGET}$"; then
      eww open "$WIDGET"
      echo "[toggle_date] opened ($windows windows)"
    fi
  else
    # Close only if currently open
    if eww list-windows | grep -q "^${WIDGET}$"; then
      eww close "$WIDGET"
      echo "[toggle_date] closed ($windows windows)"
    fi
  fi
}

# Initial sync
ensure_state

# Path to socket2 (events)
SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# Listen to Hyprland events
socat -U - UNIX-CONNECT:"$SOCK" | while read -r line; do
  case "$line" in
    openwindow*|closewindow*|movewindow*|activewindow*|workspace*|focusedmon*|createworkspace*|destroyworkspace*)
      ensure_state
      ;;
  esac
done

