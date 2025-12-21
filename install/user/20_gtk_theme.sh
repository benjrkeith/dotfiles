#!/usr/bin/env bash
# Downloads Dracula GTK theme and applies it

set -euo pipefail

theme="Dracula"
url="https://github.com/dracula/gtk/archive/master.zip"

home="${HOME}"
config="${home}/.config"
themes="${home}/.themes"
gtk4="${config}/gtk-4.0"
theme_path="${themes}/${theme}"

download_and_install_theme() {
  # If already installed, skip download
  if [[ -d "${theme_path}" ]]; then
    echo "Theme already present: ${theme_path}"
    return 0
  fi

  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf -- "'"$tmp"'"' RETURN

  echo "Downloading Dracula GTK theme..."
  curl -fsSL "${url}" -o "${tmp}/theme.zip"
  unzip -q "${tmp}/theme.zip" -d "${tmp}"

  # GitHub zip extracts to gtk-master
  local extracted
  extracted="$(find "${tmp}" -maxdepth 1 -type d -name "gtk-*" -print -quit)"
  [[ -n "${extracted}" ]] || { echo "Could not find extracted theme directory."; exit 1; }

  mkdir -p "${themes}"
  mv "${extracted}" "${theme_path}"

  echo "Installed theme to: ${theme_path}"
  trap - RETURN
}

apply_theme_symlinks() {
  echo -e "Setting theme to ${theme}"
  mkdir -p "${gtk4}"

  ln -sf  "${theme_path}/gtk-4.0/gtk.css"      "${gtk4}/gtk.css"
  ln -sf  "${theme_path}/gtk-4.0/gtk-dark.css" "${gtk4}/gtk-dark.css"
  ln -sfn "${theme_path}/gtk-4.0/assets"       "${gtk4}/assets"
  ln -sfn "${theme_path}/assets"               "${config}/assets"
}

main() {
  download_and_install_theme
  apply_theme_symlinks

  gsettings set org.gnome.desktop.interface gtk-theme "Dracula"
  gsettings set org.gnome.desktop.wm.preferences theme "Dracula"
}

main "$@"
