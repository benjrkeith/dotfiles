#!/usr/bin/env bash
set -euo pipefail

RULES_PATH="/etc/udev/rules.d/50-zsa.rules"

die() { echo "Error: $*" >&2; exit 1; }

# Re-run as root if needed
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  exec sudo bash "$0" "$@"
fi

# Figure out which user to add to plugdev
TARGET_USER="${SUDO_USER:-${USER:-}}"
[[ -n "$TARGET_USER" ]] || die "Could not determine target user (SUDO_USER/USER empty)"
[[ "$TARGET_USER" != "root" ]] || die "Refusing to modify group membership for root"

echo "Target user: $TARGET_USER"

# 1) Write udev rules file
install -d -m 0755 /etc/udev/rules.d

cat >"$RULES_PATH" <<'EOF'
# Rules for Oryx web flashing and live training
KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

# Legacy rules for live training over webusb (Not needed for firmware v21+)
  # Rule for all ZSA keyboards
  SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
  # Rule for the Moonlander
  SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
  # Rule for the Ergodox EZ
  SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
  # Rule for the Planck EZ
  SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

# Wally Flashing rules for the Ergodox EZ
ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

# Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
# Keymapp Flashing rules for the Voyager
SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
EOF

chmod 0644 "$RULES_PATH"
echo "Wrote: $RULES_PATH"

# 2) Ensure plugdev group exists
if ! getent group plugdev >/dev/null; then
  groupadd plugdev
  echo "Created group: plugdev"
else
  echo "Group already exists: plugdev"
fi

# 3) Add user to plugdev group
usermod -aG plugdev "$TARGET_USER"
echo "Added $TARGET_USER to plugdev"

# 4) Reload udev rules (no reboot needed just to load the file)
udevadm control --reload-rules
udevadm trigger
echo "Reloaded udev rules."
echo "Done."