#!/usr/bin/env python3
import argparse
import os
from pathlib import Path
import re
import tempfile
from typing import Optional, Sequence

if __package__ in (None, ""):
    import sys

    sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from tools.ci.secret_leakage import assert_secret_safe_text


_COMMIT_SHA_PATTERN = re.compile(r"^[0-9a-f]{40}$")
_REMOTE_EVENT_STATUSES = (
    "not-executed",
    "requested",
    "verified",
    "failed",
)
_SYMBOLICATION_STATUSES = (
    "not-executed",
    "uploaded",
    "verified",
    "failed",
)


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True)
    parser.add_argument("--platform", required=True)
    parser.add_argument("--environment", default="staging")
    parser.add_argument("--commit-sha", required=True)
    parser.add_argument("--release", required=True)
    parser.add_argument(
        "--remote-event-status",
        default="not-executed",
        choices=_REMOTE_EVENT_STATUSES,
    )
    parser.add_argument(
        "--symbolication-status",
        default="not-executed",
        choices=_SYMBOLICATION_STATUSES,
    )
    parser.add_argument("--remote-event-marker")
    args = parser.parse_args(argv)

    if args.platform not in {"android", "ios"}:
        parser.error("platform must be android or ios")
    if not _COMMIT_SHA_PATTERN.fullmatch(args.commit_sha):
        parser.error("commit SHA must be a lowercase 40-character SHA")
    for field_name, value in (
        ("environment", args.environment),
        ("release", args.release),
    ):
        if not value or len(value) > 128 or any(
            character in value for character in ("\r", "\n", "\x00")
        ):
            parser.error(f"{field_name} must be a bounded single-line value")
    if args.remote_event_status == "verified":
        marker = Path(args.remote_event_marker) if args.remote_event_marker else None
        if marker is None or not marker.is_file():
            parser.error("verified remote event status requires a marker file")
        marker_text = marker.read_text(encoding="utf-8")
        if "remote_event_verified=true" not in marker_text:
            parser.error("remote event marker is not authoritative")
        try:
            assert_secret_safe_text(marker_text, label="remote-event-marker")
        except ValueError as error:
            parser.error(str(error))

    output = Path(args.output)
    content = (
        "\n".join(
            [
                f"platform={args.platform}",
                f"environment={args.environment}",
                f"commit_sha={args.commit_sha}",
                f"release={args.release}",
                f"remote_event_status={args.remote_event_status}",
                f"symbolication_status={args.symbolication_status}",
            ]
        )
        + "\n"
    )
    try:
        assert_secret_safe_text(content, label="observability-evidence")
    except ValueError as error:
        parser.error(str(error))

    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        mode="w",
        encoding="utf-8",
        newline="\n",
        dir=output.parent,
        prefix=f".{output.name}.",
        delete=False,
    ) as handle:
        handle.write(content)
        temporary = Path(handle.name)
    os.replace(temporary, output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
