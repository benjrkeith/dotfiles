#!/usr/bin/env bash
# Creates python venv and installs hue_plus with pip
# This allows control of NZXT hue plus

set -euo pipefail

# Resolve target user/home even if run via sudo
target_user="${SUDO_USER:-$USER}"
target_home="$(getent passwd "$target_user" | cut -d: -f6)"

venv_dir="$target_home/.hue_plus"

# Add user to uucp group
if ! id -nG "$target_user" | tr ' ' '\n' | grep -qx 'uucp'; then
  echo "Adding $target_user to group uucp."
  sudo usermod -aG uucp "$target_user"
else
  echo "$target_user is already in uucp."
fi

# Create venv + install hue_plus
if [[ "$(id -u)" -eq 0 ]]; then
  sudo -u "$target_user" python3 -m venv "$venv_dir"
  sudo -u "$target_user" "$venv_dir/bin/pip" install --upgrade pip
  sudo -u "$target_user" "$venv_dir/bin/pip" install hue_plus
else
  python3 -m venv "$venv_dir"
  "$venv_dir/bin/pip" install --upgrade pip
  "$venv_dir/bin/pip" install hue_plus
fi

echo "Installed hue_plus into: $venv_dir"
