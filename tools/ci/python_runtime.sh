#!/usr/bin/env bash
# shellcheck shell=bash

resolve_repository_python() {
  local candidate
  if [[ -n "${PYTHON_BIN:-}" ]] && "$PYTHON_BIN" -c 'import sys; raise SystemExit(0)' >/dev/null 2>&1; then
    printf '%s\n' "$PYTHON_BIN"
    return 0
  fi
  for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c 'import sys; raise SystemExit(0)' >/dev/null 2>&1; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  echo "A working Python 3 interpreter is required." >&2
  return 1
}
