sudo tee /usr/local/bin/start-hyprland-uwsm-silent >/dev/null <<'EOF'
#!/bin/sh
set -eu

# log instead of printing on tty1
mkdir -p "$HOME/.local/state"
exec >>"$HOME/.local/state/greetd-session.log" 2>&1

# start uwsm-managed Hyprland
exec uwsm start hyprland.desktop
EOF

sudo chmod +x /usr/local/bin/start-hyprland-uwsm-silent
echo "Created silent hyprland script"
