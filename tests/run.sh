#!/bin/sh
# Test runner for rpi_tablet_os.
#
# Runs the static checks that don't need touch hardware:
#   - touchegg gesture config validation (test_gesture_config.py)
#   - `sh -n` syntax check of the shipped shell scripts
#
# Usage: sh tests/run.sh   (or ./tests/run.sh)

set -e

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)

rc=0

echo "== touchegg gesture config =="
python3 "$HERE/test_gesture_config.py" || rc=1

echo
echo "== shell script syntax (sh -n) =="
for f in \
  "$ROOT/install.sh" \
  "$ROOT/fs/home/pi/touchegg.sh" \
  "$ROOT/fs/home/pi/firefox_install.sh" \
  "$ROOT/fs/home/pi/brightness.sh"
do
  if [ -f "$f" ]; then
    if sh -n "$f" 2>/dev/null; then
      echo "  ok   - ${f#$ROOT/}"
    else
      echo "  FAIL - ${f#$ROOT/}"
      rc=1
    fi
  fi
done

echo
if [ "$rc" -eq 0 ]; then
  echo "All checks passed."
else
  echo "Some checks failed."
fi
exit "$rc"
