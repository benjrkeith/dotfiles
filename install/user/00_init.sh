#!/bin/bash
# Changes shell to zsh, creates standard user folders

set -euo pipefail

sudo chsh -s /usr/bin/zsh $USER

mkdir -p ~/code
mkdir -p ~/Documents
mkdir -p ~/Downloads
mkdir -p ~/screenshots
