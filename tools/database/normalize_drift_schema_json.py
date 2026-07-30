import argparse
import json
import os
from pathlib import Path
import tempfile
from typing import Any, Iterable, List, Optional, Sequence


def normalize_schema_payload(value: Any) -> Any:
    if isinstance(value, str):
        return value.replace("\r\n", "\n").replace("\r", "\n")
    if isinstance(value, list):
        return [normalize_schema_payload(item) for item in value]
    if isinstance(value, dict):
        return {
            key: normalize_schema_payload(item)
            for key, item in value.items()
        }
    return value


def normalize_schema_file(path: Path) -> None:
    schema_path = Path(path)
    payload = json.loads(schema_path.read_text(encoding="utf-8"))
    normalized = normalize_schema_payload(payload)
    rendered = json.dumps(
        normalized,
        ensure_ascii=False,
        indent=2,
    ) + "\n"

    descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{schema_path.name}.",
        suffix=".tmp",
        dir=str(schema_path.parent),
    )
    temporary_path = Path(temporary_name)
    try:
        with os.fdopen(
            descriptor,
            "w",
            encoding="utf-8",
            newline="\n",
        ) as handle:
            handle.write(rendered)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary_path, schema_path)
    finally:
        temporary_path.unlink(missing_ok=True)


def discover_schema_files(paths: Iterable[Path]) -> List[Path]:
    discovered = []
    for path in paths:
        candidate = Path(path)
        if candidate.is_dir():
            discovered.extend(sorted(candidate.glob("*.json")))
        elif candidate.is_file():
            discovered.append(candidate)
        else:
            raise FileNotFoundError(f"Schema path does not exist: {candidate}")
    unique = []
    seen = set()
    for path in discovered:
        resolved = path.resolve()
        if resolved not in seen:
            seen.add(resolved)
            unique.append(path)
    if not unique:
        raise ValueError("No Drift schema JSON files were found")
    return unique


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        description="Normalize line endings inside Drift schema JSON strings"
    )
    parser.add_argument("paths", nargs="+", help="Schema JSON files or directories")
    args = parser.parse_args(argv)

    files = discover_schema_files(Path(value) for value in args.paths)
    for path in files:
        normalize_schema_file(path)
    print(f"Normalized {len(files)} Drift schema JSON file(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
