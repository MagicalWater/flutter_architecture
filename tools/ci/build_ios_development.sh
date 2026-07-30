#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail
"$(dirname "$0")/build_ios_environment.sh" development Development Debug-development iphonesimulator lib/main_development.dart mock
