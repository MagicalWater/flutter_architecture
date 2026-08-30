#!/usr/bin/env python3
import json
import sys
from pathlib import Path


def main() -> int:
    environment = sys.argv[1]
    root = Path(__file__).resolve().parents[2]
    candidates = sorted(
        path.parent.parent
        for path in (root / "apps").glob("*/config/environments.json")
        if path.is_file()
    )
    if len(candidates) != 1:
        raise SystemExit(f"Expected exactly one app environment manifest; found {len(candidates)}")
    app_root = candidates[0]
    manifest = json.loads(
        (app_root / "config/environments.json").read_text(encoding="utf-8")
    )
    environment_map = {item["name"]: item for item in manifest["environments"]}
    expected_package = environment_map[environment]["androidApplicationId"]
    config = app_root / "android/app/src" / environment / "google-services.json"
    if not config.is_file():
        print(f"Firebase Android config not present for {environment}; provider wiring not executed.")
        return 0

    payload = json.loads(config.read_text())
    app_id = payload.get("client", [{}])[0].get("client_info", {}).get("mobilesdk_app_id")
    packages = {
        client.get("client_info", {}).get("android_client_info", {}).get("package_name")
        for client in payload.get("client", [])
    }
    if expected_package not in packages:
        raise SystemExit(
            f"Firebase config package mismatch for {environment}: expected {expected_package}",
        )
    if not isinstance(app_id, str) or not app_id.strip():
        raise SystemExit(f"Firebase config mobilesdk_app_id missing for {environment}")
    print(f"Firebase Android config verified for {environment}: package={expected_package}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
