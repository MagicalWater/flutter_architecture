#!/usr/bin/env python3
import json
import plistlib
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
    expected_bundle = environment_map[environment]["iosBundleIdentifier"]
    config = (
        app_root
        / "ios/Firebase"
        / environment
        / "GoogleService-Info.plist"
    )
    if not config.is_file():
        print(
            f"Firebase iOS config not present for {environment}; provider wiring not executed.",
        )
        return 0

    with config.open("rb") as stream:
        payload = plistlib.load(stream)

    bundle_id = payload.get("BUNDLE_ID")
    app_id = payload.get("GOOGLE_APP_ID")
    if bundle_id != expected_bundle:
        raise SystemExit(
            f"Firebase config bundle mismatch for {environment}: expected {expected_bundle}",
        )
    if not isinstance(app_id, str) or not app_id.strip():
        raise SystemExit(f"Firebase config GOOGLE_APP_ID missing for {environment}")

    print(f"Firebase iOS config verified for {environment}: bundle={expected_bundle}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
