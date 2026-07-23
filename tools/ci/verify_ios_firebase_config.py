#!/usr/bin/env python3
import plistlib
import sys
from pathlib import Path


BUNDLE_IDS = {
    "development": "com.example.flutterarchitecture.development",
    "staging": "com.example.flutterarchitecture.staging",
    "production": "com.example.flutterarchitecture",
}


def main() -> int:
    environment = sys.argv[1]
    expected_bundle = BUNDLE_IDS[environment]
    root = Path(__file__).resolve().parents[2]
    config = (
        root
        / "apps/flutter_architecture/ios/Firebase"
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
