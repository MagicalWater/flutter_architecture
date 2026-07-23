#!/usr/bin/env bash
set -euo pipefail

root="${1:-}"
if [[ -z "$root" || "$root" == "/" || "$root" == "$HOME" ]]; then
  echo "Refusing unsafe CI secret cleanup root: ${root:-<empty>}" >&2
  exit 64
fi

if [[ ! -d "$root" ]]; then
  exit 0
fi

names=(
  firebase-service-account.json
  service-account.json
  google-services.json
  GoogleService-Info.plist
)

for name in "${names[@]}"; do
  while IFS= read -r -d '' file; do
    rm -f -- "$file"
  done < <(find "$root" -type f -name "$name" -print0)
done

for name in "${names[@]}"; do
  if find "$root" -type f -name "$name" -print -quit | grep -q .; then
    echo "CI secret cleanup failed for file name: $name" >&2
    exit 1
  fi
done
