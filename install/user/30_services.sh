#!/bin/bash
# Enables all required services

set -euo pipefail

sudo systemctl enable bluetooth

systemctl --user enable pipewire 
systemctl --user enable pipewire-pulse 
systemctl --user enable wireplumber
systemctl --user enable hyprpaper
systemctl --user enable waybar
systemctl --user enable elephant
systemctl --user enable walker
systemctl --user enable hue_plus
systemctl --user enable goxlr
systemctl --user enable udiskie