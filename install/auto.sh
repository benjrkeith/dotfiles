#!/usr/bin/env bash
# Executes all scripts inside of another directory
# Usage: bash auto.sh <directory>

set -euo pipefail
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
target_dir="${script_dir}/${1:?Missing directory name}"

if [[ ! -d "$target_dir" ]]; then
  echo "Not a directory: $target_dir" >&2
  exit 1
fi

shopt -s nullglob

for f in "$target_dir"/*.sh; do
  base="$(basename -- "$f")"

  # ignore files starting with _ or non executeable
  [[ "$base" == _* ]] && echo "=> $base Skipping (disabled)" && continue
  [[ ! -x "$f" ]] && echo "=> $base Skipping (not executable)" && continue

  echo "=> $base - Running"
  "$f"
done
