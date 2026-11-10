#!/usr/bin/env bash
# Install the Chrome-only auto-update timer on the kiosk.
#   sudo ./install.sh          install, enable, and upgrade Chrome right now
#   sudo ./install.sh remove   disable and remove the timer
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

if [ "$(id -u)" -ne 0 ]; then
    echo "Run with sudo: sudo $0 ${1:-}" >&2
    exit 1
fi

if [ "${1:-}" = "remove" ]; then
    systemctl disable --now kiosk-chrome-update.timer || true
    rm -f /etc/systemd/system/kiosk-chrome-update.{service,timer}
    systemctl daemon-reload
    echo "Removed."
    exit 0
fi

install -m 0644 kiosk-chrome-update.service kiosk-chrome-update.timer /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now kiosk-chrome-update.timer

echo "Upgrading Chrome now..."
systemctl start kiosk-chrome-update.service
rpm -q google-chrome-stable
systemctl list-timers kiosk-chrome-update.timer --no-pager
echo "Done. Reboot to run the new Chrome."
