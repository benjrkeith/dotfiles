#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SECTIONS_DIR="${SECTIONS_DIR:-$ROOT_DIR/sections}"

die() { echo "error: $*" >&2; exit 1; }

usage() {
  echo "Usage:"
  echo "  $(basename "$0")              # run all section folders"
  echo "  $(basename "$0") all          # run all section folders"
  echo "  $(basename "$0") <name> ...   # run only named section folders"
  echo
  echo "Available sections:"
  list_sections || true
}

list_sections() {
  [[ -d "$SECTIONS_DIR" ]] || return 0
  find "$SECTIONS_DIR" -mindepth 1 -maxdepth 1 -type d -printf '  %f\n' | sort
}

run_folder_scripts() {
  local section="$1"
  local dir="$SECTIONS_DIR/$section"
  [[ -d "$dir" ]] || die "unknown section: $section (no such folder: $dir)"

  echo "===== SECTION: $section ====="

  shopt -s nullglob
  local scripts=("$dir"/*.sh)
  shopt -u nullglob

  ((${#scripts[@]})) || { echo "note: no .sh scripts in $dir"; return 0; }

  # Run in a deterministic order
  IFS=$'\n' scripts=($(printf '%s\n' "${scripts[@]}" | sort))
  unset IFS

  for s in "${scripts[@]}"; do
    echo "==> ${section}/$(basename "$s")"
    bash "$s"
  done
}

run_all() {
  [[ -d "$SECTIONS_DIR" ]] || die "missing sections dir: $SECTIONS_DIR"

  mapfile -t sections < <(find "$SECTIONS_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
  ((${#sections[@]})) || die "no section folders found in $SECTIONS_DIR"

  for sec in "${sections[@]}"; do
    run_folder_scripts "$sec"
  done
}

# ---- main ----
case "${1:-}" in
  ""|"all"|"0")
    run_all
    ;;
  "-h"|"--help")
    usage
    ;;
  *)
    for sec in "$@"; do
      run_folder_scripts "$sec"
    done
    ;;
esac
