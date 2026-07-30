#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail
"$(dirname "$0")/build_android_environment.sh" production release lib/main_production.dart real
