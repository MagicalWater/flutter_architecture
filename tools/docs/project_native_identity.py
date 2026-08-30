from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


IDENTIFIER_RE = re.compile(r"^[A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z][A-Za-z0-9_]*)+$")


def discover_app_root(root: Path) -> Path:
    candidates = sorted(
        path.parent.parent
        for path in (root / "apps").glob("*/config/environments.json")
        if path.is_file()
    )
    if len(candidates) != 1:
        raise RuntimeError(f"expected exactly one app environment manifest; found {len(candidates)}")
    return candidates[0]


def project_native_identity(
    root: Path,
    base_identifier: str,
    development_name: str,
    staging_name: str,
    production_name: str,
) -> None:
    if not IDENTIFIER_RE.fullmatch(base_identifier):
        raise RuntimeError("base identifier must be a Kotlin-compatible reverse-domain identifier")
    app_root = discover_app_root(root)
    manifest_path = app_root / "config/environments.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    if manifest.get("schemaVersion") != 2:
        raise RuntimeError("native projection requires environment manifest schemaVersion 2")

    display_names = {
        "development": development_name,
        "staging": staging_name,
        "production": production_name,
    }
    manifest["baseIdentifier"] = base_identifier
    for environment in manifest["environments"]:
        name = environment["name"]
        identifier = base_identifier if name == "production" else f"{base_identifier}.{name}"
        environment["displayName"] = display_names[name]
        environment["androidApplicationId"] = identifier
        environment["iosBundleIdentifier"] = identifier
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    kotlin_root = app_root / "android/app/src/main/kotlin"
    activities = list(kotlin_root.rglob("MainActivity.kt"))
    if len(activities) != 1:
        raise RuntimeError(f"expected exactly one MainActivity.kt; found {len(activities)}")
    old_activity = activities[0]
    activity_text = old_activity.read_text(encoding="utf-8")
    activity_text = re.sub(r"^package\s+\S+", f"package {base_identifier}", activity_text, count=1, flags=re.MULTILINE)
    new_activity = kotlin_root.joinpath(*base_identifier.split("."), "MainActivity.kt")
    new_activity.parent.mkdir(parents=True, exist_ok=True)
    new_activity.write_text(activity_text, encoding="utf-8")
    if new_activity != old_activity:
        old_activity.unlink()
        parent = old_activity.parent
        while parent != kotlin_root and parent.exists() and not any(parent.iterdir()):
            parent.rmdir()
            parent = parent.parent

    ios_flutter = app_root / "ios/Flutter"
    environment_map = {item["name"]: item for item in manifest["environments"]}
    for environment, item in environment_map.items():
        for mode in ("Debug", "Profile", "Release"):
            config = ios_flutter / f"{mode}-{environment}.xcconfig"
            text = config.read_text(encoding="utf-8")
            replacements = {
                "PRODUCT_BUNDLE_IDENTIFIER": item["iosBundleIdentifier"],
                "APP_DISPLAY_NAME": item["displayName"],
                "PRODUCT_NAME": item["displayName"],
            }
            for key, value in replacements.items():
                text = re.sub(rf"^{key}\s*=.*$", f"{key} = {value}", text, flags=re.MULTILINE)
            config.write_text(text, encoding="utf-8", newline="")

    project = app_root / "ios/Runner.xcodeproj/project.pbxproj"
    project_text = project.read_text(encoding="utf-8")
    project_text = re.sub(
        r"PRODUCT_BUNDLE_IDENTIFIER\s*=\s*[^;]+\.RunnerTests;",
        f"PRODUCT_BUNDLE_IDENTIFIER = {base_identifier}.RunnerTests;",
        project_text,
    )
    project.write_text(project_text, encoding="utf-8", newline="")


def main() -> int:
    parser = argparse.ArgumentParser(description="Project manifest-owned native product identity")
    parser.add_argument("base_identifier")
    parser.add_argument("--development-name", required=True)
    parser.add_argument("--staging-name", required=True)
    parser.add_argument("--production-name", required=True)
    parser.add_argument("--root", default=".")
    args = parser.parse_args()
    project_native_identity(
        Path(args.root).resolve(),
        args.base_identifier,
        args.development_name,
        args.staging_name,
        args.production_name,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
