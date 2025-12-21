#!/usr/bin/env bash
set -euo pipefail

CONF="/etc/greetd/config.toml"

die() { echo "Error: $*" >&2; exit 1; }

# Re-run as root if needed
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  exec sudo -E bash "$0" "$@"
fi

# Pick the target user (best-effort)
TARGET_USER="${SUDO_USER:-}"
if [[ -z "${TARGET_USER}" || "${TARGET_USER}" == "root" ]]; then
  TARGET_USER="$(logname 2>/dev/null || true)"
fi
[[ -n "${TARGET_USER}" && "${TARGET_USER}" != "root" ]] || die "Could not determine target user. Run via: sudo -E $0"

echo "Target user: ${TARGET_USER}"

# Install packages
echo "Installing greetd..."
pacman -S --needed --noconfirm greetd greetd-agreety

# Backup existing config
mkdir -p /etc/greetd
if [[ -f "$CONF" ]]; then
  backup="${CONF}.bak.$(date +%Y%m%d-%H%M%S)"
  cp -a "$CONF" "$backup"
  echo "Backup: $backup"
fi

# Write greetd config:
# - initial_session: auto-login (runs once per boot) :contentReference[oaicite:2]{index=2}
# - default_session: restart Hyprland automatically if you log out (still no prompt)
cat > "$CONF" <<EOF
[terminal]
vt = 1

[initial_session]
command = "uwsm start hyprland.desktop"
user = "${TARGET_USER}"

[default_session]
command = "uwsm start hyprland.desktop"
user = "${TARGET_USER}"
EOF

echo "Wrote: $CONF"

# Avoid tty1 conflict (recommended if using a specific VT) :contentReference[oaicite:3]{index=3}
echo "Disabling getty on tty1 and enabling greetd..."
systemctl disable --now getty@tty1.service || true
systemctl enable --now greetd.service

echo
echo "Done. Reboot now."
echo "If you need a rescue TTY, switch to Ctrl+Alt+F2 and log in there."
