#!/usr/bin/env bash
# Creates python venv and installs hue_plus with pip
# This allows control of NZXT hue plus

set -euo pipefail

# Resolve target user/home even if run via sudo
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

VENV_DIR="$TARGET_HOME/.hue_plus"
PYTHON_BIN="${PYTHON_BIN:-python3}"

# Add user to uucp group
if ! id -nG "$TARGET_USER" | tr ' ' '\n' | grep -qx 'uucp'; then
  echo "Adding $TARGET_USER to group uucp."
  sudo usermod -aG uucp "$TARGET_USER"
else
  echo "$TARGET_USER is already in uucp."
fi

# Create venv + install hue_plus
if [[ "$(id -u)" -eq 0 ]]; then
  sudo -u "$TARGET_USER" "$PYTHON_BIN" -m venv "$VENV_DIR"
  sudo -u "$TARGET_USER" "$VENV_DIR/bin/pip" install --upgrade pip
  sudo -u "$TARGET_USER" "$VENV_DIR/bin/pip" install hue_plus
else
  "$PYTHON_BIN" -m venv "$VENV_DIR"
  "$VENV_DIR/bin/pip" install --upgrade pip
  "$VENV_DIR/bin/pip" install hue_plus
fi

echo "Installed hue_plus into: $VENV_DIR"
