#!/usr/bin/env python3
import argparse
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True)
    parser.add_argument("--platform", required=True)
    parser.add_argument("--environment", default="staging")
    parser.add_argument("--commit-sha", required=True)
    parser.add_argument("--release", required=True)
    parser.add_argument("--remote-event-status", default="not-executed")
    parser.add_argument("--symbolication-status", default="not-executed")
    args = parser.parse_args()

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
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
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
