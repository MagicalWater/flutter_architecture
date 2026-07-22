#!/usr/bin/env bash
set -euo pipefail
"$(dirname "$0")/build_android_environment.sh" development debug lib/main_development.dart mock
