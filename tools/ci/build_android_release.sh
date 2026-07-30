#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail
exec "$(dirname "$0")/build_android_production.sh"
