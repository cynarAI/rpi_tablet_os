#!/bin/sh
echo "Installing Raspberry Pi Tablet OS..."
sudo apt update
sudo apt full-upgrade
# Core packages: present across Raspberry Pi OS / Debian releases.
sudo apt install -y onboard at-spi2-core git xorg-dev bluetooth bluez blueman pulseaudio libx11-6 libxtst-dev dconf-cli

# Some packages were renamed or dropped on newer Debian (trixie+):
#   libgles2-mesa      -> libgles2
#   libgles2-mesa-dev  -> libgles-dev
#   libqt4-dev         -> removed (Qt4 is gone; only needed by the bundled
#                         legacy touchegg .deb, see README troubleshooting)
#   libgrail6          -> removed (legacy uTouch gesture lib)
# Install these best-effort: try each candidate name and warn instead of
# aborting the whole install when none is available.
install_optional() {
  for pkg in "$@"; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      sudo apt install -y "$pkg" && return 0
    fi
  done
  echo "WARN: skipping unavailable package(s): $*" >&2
  return 0
}

install_optional libgles2 libgles2-mesa
install_optional libgles-dev libgles2-mesa-dev
install_optional libqt4-dev
install_optional libgrail6

sudo apt remove -y bluealsa

rm -rf rpi_tablet_os
git clone https://github.com/tobykurien/rpi_tablet_os.git rpi_tablet_os
cd rpi_tablet_os/fs
sudo cp -r * /

# fix ownership of files in pi home directory
sudo chown -R pi:pi /home/pi

sudo dpkg -i install /home/pi/touchegg_*.deb

dconf load /org/onboard/ < ~/onboard.dconf

echo "Installation complete, rebooting..."
sleep 10s
sudo reboot
