#!/bin/bash
# =============================================================
# MediaControl - Unified MPD + MPRIS player controller
# With reliable cover art + YouTube thumbnail support
# =============================================================

# Check dependencies
check_deps() {
  local deps=("playerctl" "mpc" "ffmpeg" "curl")
  local missing=()

  for dep in "${deps[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1; then
      missing+=("$dep")
    fi
  done

  if [ ${#missing[@]} -ne 0 ]; then
    echo "Missing dependencies: ${missing[*]}"
    echo "Install with: sudo zypper install ${missing[*]}"
    exit 1
  fi
}

check_deps

# Player priority: Spotify > MPRIS > MPD
if pgrep -x spotify >/dev/null 2>&1; then
  Control="spotify"
elif playerctl -l 2>/dev/null | grep -q .; then
  Control="$(playerctl -l | head -n1)"
else
  Control="MPD"
fi

# Vars
Cover=/tmp/cover.png
bkpCover=~/.config/bspwm/src/assets/fallback.webp
mpddir=~/Music
LAST_SONG_FILE="/tmp/last_song.txt"

# Create fallback cover if it doesn't exist
if [ ! -f "$bkpCover" ]; then
  mkdir -p "$(dirname "$bkpCover")"
  # Create a simple colored square as fallback
  convert -size 300x300 xc:'#2d3748' "$bkpCover" 2>/dev/null || {
    # If ImageMagick is not available, use a different approach
    curl -sL "https://via.placeholder.com/300x300/2d3748/ffffff?text=No+Cover" -o "$bkpCover" 2>/dev/null || {
      touch "$bkpCover"
    }
  }
fi

# -------- Functions ----------
fetch_youtube_thumb() {
  video_id="$1"
  # Try maxres first, fallback to hq
  curl -sL "https://img.youtube.com/vi/$video_id/maxresdefault.jpg" -o "$Cover" ||
    curl -sL "https://img.youtube.com/vi/$video_id/hqdefault.jpg" -o "$Cover" ||
    cp "$bkpCover" "$Cover"
}

extract_ffmpeg_thumb() {
  ffmpeg -ss 00:00:05 -i "$1" -vframes 1 -q:v 2 "$Cover" -y >/dev/null 2>&1 ||
    cp "$bkpCover" "$Cover"
}

# -------- Main logic ----------
case $Control in
MPD)
  case $1 in
  --next) mpc -q next ;;
  --previous) mpc -q prev ;;
  --toggle) mpc -q toggle ;;
  --stop) mpc -q stop ;;
  --title)
    title=$(mpc -f %title% current)
    echo "${title:-Play Something}"
    ;;
  --artist)
    artist=$(mpc -f %artist% current)
    echo "${artist:-No Artist}"
    ;;
  --status)
    status=$(mpc status | sed -En '2s/.*\[([^]]*)\].*/\u\1/p')
    echo "${status:-Stopped}"
    ;;
  --player) echo "$Control" ;;
  --cover)
    current_song=$(mpc current -f "%title%-%artist%")
    last_song=$(cat "$LAST_SONG_FILE" 2>/dev/null || echo "")
    if [ "$current_song" != "$last_song" ] || [ ! -f "$Cover" ]; then
      ffmpeg -i "$mpddir/$(mpc current -f %file%)" "$Cover" -y >/dev/null 2>&1 ||
        cp "$bkpCover" "$Cover"
      echo "$current_song" >"$LAST_SONG_FILE"
    fi
    echo "$Cover"
    ;;
  --position) mpc status %currenttime% ;;
  --positions) mpc status %currenttime% | awk -F: '{print ($1 * 60) + $2}' ;;
  --length) mpc status %totaltime% ;;
  --lengths) mpc status %totaltime% | awk -F: '{print ($1 * 60) + $2}' ;;
  --shuffle) mpc status | sed -n '3s/.*random: \([^ ]*\).*/\1/p' | sed 's/.*/\u&/' ;;
  --loop) mpc status | sed -n '3s/.*repeat: \([^ ]*\).*/\1/p' | sed 's/.*/\u&/' ;;
  *)
    echo "Usage: $0 [--next|--previous|--toggle|--stop|--title|--artist|--status|--player|--cover|--position|--positions|--length|--lengths|--shuffle|--loop]"
    ;;
  esac
  ;;
*)
  case $1 in
  --next) playerctl --player="$Control" next ;;
  --previous) playerctl --player="$Control" previous ;;
  --toggle) playerctl --player="$Control" play-pause ;;
  --stop) playerctl --player="$Control" stop ;;
  --title)
    title=$(playerctl --player="$Control" metadata --format "{{title}}")
    echo "${title:-Play Something}"
    ;;
  --artist)
    artist=$(playerctl --player="$Control" metadata --format "{{artist}}")
    echo "${artist:-No Artist}"
    ;;
  --status) playerctl --player="$Control" status ;;
  --player) echo "$Control" ;;
  --cover)
    current_song="$(playerctl --player="$Control" metadata --format '{{title}}-{{artist}}')"
    last_song=$(cat "$LAST_SONG_FILE" 2>/dev/null || echo "")
    if [ "$current_song" != "$last_song" ] || [ ! -f "$Cover" ]; then
      art_url=$(playerctl --player="$Control" metadata mpris:artUrl)
      media_url=$(playerctl --player="$Control" metadata xesam:url)
      if [ -n "$art_url" ]; then
        curl -sL "$art_url" -o "$Cover" || cp "$bkpCover" "$Cover"
      elif echo "$media_url" | grep -q "youtube.com"; then
        video_id=$(echo "$media_url" | sed -n 's/.*v=\([^&]*\).*/\1/p')
        [ -n "$video_id" ] && fetch_youtube_thumb "$video_id" || cp "$bkpCover" "$Cover"
      elif [ -n "$media_url" ]; then
        extract_ffmpeg_thumb "$media_url"
      else
        cp "$bkpCover" "$Cover"
      fi
      echo "$current_song" >"$LAST_SONG_FILE"
    fi
    echo "$Cover"
    ;;
  --position) playerctl --player="$Control" position --format "{{ duration(position) }}" ;;
  --positions) playerctl --player="$Control" position | sed 's/..\{6\}$//' ;;
  --length) playerctl --player="$Control" metadata --format "{{ duration(mpris:length) }}" ;;
  --lengths) playerctl --player="$Control" metadata mpris:length | sed 's/.\{6\}$//' ;;
  --shuffle) playerctl --player="$Control" shuffle ;;
  --loop) playerctl --player="$Control" loop ;;
  *)
    echo "Usage: $0 [--next|--previous|--toggle|--stop|--title|--artist|--status|--player|--cover|--position|--positions|--length|--lengths|--shuffle|--loop]"
    ;;
  esac
  ;;
esac 2>/dev/null
