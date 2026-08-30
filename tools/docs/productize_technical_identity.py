from __future__ import annotations

import argparse
import re
import subprocess
from pathlib import Path


PACKAGE_RE = re.compile(r"^[a-z][a-z0-9_]*$")
GENERATED_SUFFIXES = (".g.dart", ".freezed.dart", ".gr.dart", ".gen.dart")


def _read_package_name(pubspec: Path) -> str:
    for line in pubspec.read_text(encoding="utf-8").splitlines():
        if line.startswith("name:"):
            return line.split(":", 1)[1].strip()
    raise RuntimeError(f"Package name missing: {pubspec}")


def _tracked_files(root: Path) -> tuple[Path, ...]:
    output = subprocess.check_output(
        ["git", "-C", str(root), "ls-files"], text=True, encoding="utf-8"
    )
    return tuple(root / line for line in output.splitlines() if line.strip())


def _is_generated(path: Path) -> bool:
    return path.name == "injection.config.dart" or path.name.endswith(GENERATED_SUFFIXES)


def _is_historical(root: Path, path: Path) -> bool:
    relative = path.relative_to(root).as_posix()
    return (
        relative == "CHANGELOG.md"
        or relative.startswith("docs/archive/")
        or relative.startswith("docs/audits/")
        or relative.startswith("docs/milestones/")
    )


def _replace_text(path: Path, replacements: tuple[tuple[str, str], ...], dry_run: bool) -> bool:
    try:
        original = path.read_text(encoding="utf-8")
    except (UnicodeDecodeError, OSError):
        return False
    updated = original
    for old, new in replacements:
        updated = updated.replace(old, new)
    if updated == original:
        return False
    if not dry_run:
        path.write_text(updated, encoding="utf-8", newline="")
    return True


def productize(root: Path, app_name: str, *, dry_run: bool) -> list[str]:
    if not PACKAGE_RE.fullmatch(app_name):
        raise RuntimeError("app name must be a valid lower_snake_case Dart package name")

    manifests = sorted((root / "apps").glob("*/config/environments.json"))
    if len(manifests) != 1:
        raise RuntimeError(
            "technical identity migration requires exactly one executable app environment manifest"
        )
    old_app_root = manifests[0].parent.parent
    old_dir_name = old_app_root.name
    old_package_name = _read_package_name(old_app_root / "pubspec.yaml")
    new_app_root = old_app_root.parent / app_name
    if new_app_root != old_app_root and new_app_root.exists():
        raise RuntimeError(f"target app directory already exists: {new_app_root}")

    old_app_path = f"apps/{old_dir_name}"
    new_app_path = f"apps/{app_name}"
    replacements = (
        (old_app_path, new_app_path),
        (f"package:{old_package_name}/", f"package:{app_name}/"),
        (f"--scope={old_package_name}", f"--scope={app_name}"),
    )

    changed: list[str] = []
    for path in _tracked_files(root):
        if _is_generated(path) or _is_historical(root, path):
            continue
        if _replace_text(path, replacements, dry_run):
            changed.append(path.relative_to(root).as_posix())

    app_pubspec = old_app_root / "pubspec.yaml"
    if app_pubspec.is_file():
        source = app_pubspec.read_text(encoding="utf-8")
        updated = re.sub(rf"^name:\s*{re.escape(old_package_name)}\s*$", f"name: {app_name}", source, count=1, flags=re.MULTILINE)
        if updated != source:
            if not dry_run:
                app_pubspec.write_text(updated, encoding="utf-8", newline="")
            changed.append(app_pubspec.relative_to(root).as_posix())

    root_pubspec = root / "pubspec.yaml"
    source = root_pubspec.read_text(encoding="utf-8")
    updated = re.sub(r"^name:\s*\S+\s*$", f"name: {app_name}_workspace", source, count=1, flags=re.MULTILINE)
    if updated != source:
        if not dry_run:
            root_pubspec.write_text(updated, encoding="utf-8", newline="")
        changed.append("pubspec.yaml")

    if new_app_root != old_app_root:
        changed.append(f"MOVE {old_app_path} -> {new_app_path}")
        if not dry_run:
            old_app_root.rename(new_app_root)

    return sorted(set(changed))


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Productize executable app/workspace technical identity without touching compatibility identity"
    )
    parser.add_argument("app_name", help="lower_snake_case product technical name")
    parser.add_argument("--root", default=".")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    changed = productize(Path(args.root).resolve(), args.app_name, dry_run=args.dry_run)
    for item in changed:
        print(item)
    if not changed:
        print("Technical identity already matches requested product name.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
