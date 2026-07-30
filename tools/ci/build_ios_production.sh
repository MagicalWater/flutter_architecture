#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail
"$(dirname "$0")/build_ios_environment.sh" production Production Release-production iphoneos lib/main_production.dart real
