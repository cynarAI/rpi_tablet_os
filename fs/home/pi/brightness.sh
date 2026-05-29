#!/bin/sh
# brightness.sh - screen brightness control for Raspberry Pi tablets.
#
# Usage:
#   brightness.sh get          print current brightness as 0-100
#   brightness.sh <0-100>      set absolute brightness percent
#   brightness.sh +<n>         increase by n percent
#   brightness.sh -<n>         decrease by n percent
#
# Prefers a real hardware backlight under /sys/class/backlight (e.g. the
# official Raspberry Pi DSI touchscreen). For HDMI screens that have no
# backlight driver it falls back to xrandr software gamma dimming - this only
# dims the image visually and does not save power.

set -e

clamp() {
  v=$1
  [ "$v" -lt 0 ] && v=0
  [ "$v" -gt 100 ] && v=100
  echo "$v"
}

BL=$(ls -d /sys/class/backlight/*/ 2>/dev/null | head -n 1)

if [ -n "$BL" ]; then
  max=$(cat "${BL}max_brightness")
  cur=$(cat "${BL}brightness")
  cur_pct=$(( cur * 100 / max ))
  case "$1" in
    get|"") echo "$cur_pct"; exit 0 ;;
    +*)     target=$(( cur_pct + ${1#+} )) ;;
    -*)     target=$(( cur_pct - ${1#-} )) ;;
    *)      target=$1 ;;
  esac
  target=$(clamp "$target")
  val=$(( target * max / 100 ))
  # On Raspberry Pi OS a udev rule usually makes this writable by the video
  # group; fall back to sudo if not.
  if ! echo "$val" > "${BL}brightness" 2>/dev/null; then
    echo "$val" | sudo tee "${BL}brightness" >/dev/null
  fi
  echo "$target"
else
  # No hardware backlight - software dimming via xrandr.
  OUT=$(xrandr --query | awk '/ connected/{print $1; exit}')
  [ -z "$OUT" ] && { echo "No connected display found" >&2; exit 1; }
  case "$1" in
    get|"") xrandr --verbose | awk '/Brightness/{printf "%d\n", $2 * 100; exit}'; exit 0 ;;
    +*|-*)  echo "Relative adjustment is not supported in the xrandr fallback; pass an absolute 0-100 value." >&2; exit 1 ;;
    *)      target=$(clamp "$1") ;;
  esac
  # xrandr brightness is a 0.0-1.0 multiplier; keep a 0.1 floor so the screen
  # never goes fully black and unrecoverable by touch.
  frac=$(awk "BEGIN { f = $target / 100; if (f < 0.1) f = 0.1; printf \"%.2f\", f }")
  xrandr --output "$OUT" --brightness "$frac"
  echo "$target"
fi
