#!/bin/sh
# Install Firefox on Raspberry Pi OS (Debian-based).
#
# The old approach downloaded a hardcoded Ubuntu armhf .deb from
# ftp://ports.ubuntu.com which (a) targeted the wrong distro and (b) pinned an
# obsolete version (18.04.2). Raspberry Pi OS ships Firefox in its own repos, so
# we just install from apt and fall back to firefox-esr when needed.

set -e

if sudo apt install -y firefox; then
  PKG=firefox
elif sudo apt install -y firefox-esr; then
  PKG=firefox-esr
else
  echo "Unable to install Firefox from the system repositories." >&2
  exit 1
fi

echo "$PKG installed."
echo "If hardware acceleration is needed, open about:config and set layers.acceleration.force-enabled to true."
