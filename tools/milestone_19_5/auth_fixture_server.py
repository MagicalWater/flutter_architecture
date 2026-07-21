from __future__ import annotations

import argparse
import hashlib
import json
import ssl
import threading
from collections.abc import Mapping
from dataclasses import dataclass
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import BinaryIO
from pathlib import Path
from typing import Any


ACCESS_V1 = "m19-access-v1"
REFRESH_V1 = "m19-refresh-v1"
ACCESS_V2 = "m19-access-v2"
REFRESH_V2 = "m19-refresh-v2"
USER_ID = "user-001"
USER_NAME = "Water Magical"


@dataclass(frozen=True)
class FixtureResponse:
    status: int
    body: dict[str, Any]


class AuthFixtureState:
    def __init__(self, evidence_path: Path | None = None) -> None:
        self._lock = threading.Lock()
        self._events: list[dict[str, Any]] = []
        self._refresh_count = 0
        self._access_v1_rejected = False
        self._evidence_path = evidence_path

    @property
    def refresh_count(self) -> int:
        with self._lock:
            return self._refresh_count

    def login(self, *, raw_body: str | None = None) -> FixtureResponse:
        del raw_body
        response = FixtureResponse(
            200,
            {
                "accessToken": ACCESS_V1,
                "refreshToken": REFRESH_V1,
                "userId": USER_ID,
                "userName": USER_NAME,
            },
        )
        self._record("POST", "/auth/login", response.status)
        return response

    def profile(self, authorization: str | None) -> FixtureResponse:
        token = _bearer_token(authorization)
        if token == ACCESS_V2:
            response = FixtureResponse(
                200,
                {"id": USER_ID, "name": USER_NAME},
            )
        elif token == ACCESS_V1 and not self._access_v1_rejected:
            self._access_v1_rejected = True
            response = FixtureResponse(401, {"message": "unauthorized"})
        else:
            response = FixtureResponse(401, {"message": "unauthorized"})
        self._record("GET", "/profile", response.status, token)
        return response

    def refresh(
        self,
        refresh_token: str | None,
        *,
        raw_body: str | None = None,
    ) -> FixtureResponse:
        del raw_body
        with self._lock:
            allowed = refresh_token == REFRESH_V1 and self._refresh_count == 0
            if allowed:
                self._refresh_count += 1
        if allowed:
            response = FixtureResponse(
                200,
                {
                    "accessToken": ACCESS_V2,
                    "refreshToken": REFRESH_V2,
                },
            )
        else:
            response = FixtureResponse(401, {"message": "unauthorized"})
        self._record("POST", "/auth/refresh", response.status, refresh_token)
        return response

    def evidence(self) -> list[dict[str, Any]]:
        with self._lock:
            return [dict(event) for event in self._events]

    def reset(self) -> None:
        with self._lock:
            self._events.clear()
            self._refresh_count = 0
            self._access_v1_rejected = False
        evidence_path = self._evidence_path
        if evidence_path is not None:
            evidence_path.parent.mkdir(parents=True, exist_ok=True)
            evidence_path.write_text("", encoding="utf-8")

    def _record(
        self,
        method: str,
        path: str,
        status: int,
        credential: str | None = None,
    ) -> None:
        with self._lock:
            event: dict[str, Any] = {
                "sequence": len(self._events) + 1,
                "method": method,
                "path": path,
                "status": status,
            }
            if credential:
                event["credential_fingerprint"] = _fingerprint(credential)
            self._events.append(event)
            evidence_path = self._evidence_path
            if evidence_path is not None:
                evidence_path.parent.mkdir(parents=True, exist_ok=True)
                with evidence_path.open("a", encoding="utf-8", newline="\n") as file:
                    file.write(json.dumps(event, sort_keys=True) + "\n")


class _FixtureHandler(BaseHTTPRequestHandler):
    server: "AuthFixtureHttpServer"

    def do_GET(self) -> None:  # noqa: N802
        if self.path == "/profile":
            self._send(self.server.state.profile(self.headers.get("Authorization")))
            return
        if self.path == "/evidence":
            self._send(FixtureResponse(200, {"events": self.server.state.evidence()}))
            return
        self._send(FixtureResponse(404, {"message": "not found"}))

    def do_POST(self) -> None:  # noqa: N802
        raw_body = self._read_body()
        if self.path == "/auth/login":
            self._send(self.server.state.login(raw_body=raw_body))
            return
        if self.path == "/auth/refresh":
            refresh_token = _read_refresh_token(raw_body)
            self._send(
                self.server.state.refresh(refresh_token, raw_body=raw_body),
            )
            return
        if self.path == "/reset":
            self.server.state.reset()
            self._send(FixtureResponse(200, {"reset": True}))
            return
        self._send(FixtureResponse(404, {"message": "not found"}))

    def log_message(self, format: str, *args: object) -> None:
        del format, args

    def _read_body(self) -> str:
        return _read_http_body(self.rfile, self.headers)

    def _send(self, response: FixtureResponse) -> None:
        payload = json.dumps(response.body, separators=(",", ":")).encode("utf-8")
        self.send_response(response.status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)


class AuthFixtureHttpServer(ThreadingHTTPServer):
    def __init__(self, address: tuple[str, int], state: AuthFixtureState) -> None:
        super().__init__(address, _FixtureHandler)
        self.state = state


def _bearer_token(authorization: str | None) -> str | None:
    if authorization is None or not authorization.startswith("Bearer "):
        return None
    return authorization.removeprefix("Bearer ")


def _read_refresh_token(raw_body: str) -> str | None:
    try:
        value = json.loads(raw_body)
    except json.JSONDecodeError:
        return None
    if not isinstance(value, dict):
        return None
    refresh_token = value.get("refreshToken")
    return refresh_token if isinstance(refresh_token, str) else None


def _read_http_body(stream: BinaryIO, headers: Mapping[str, str]) -> str:
    transfer_encoding = headers.get("Transfer-Encoding", "").lower()
    if "chunked" in transfer_encoding:
        chunks = bytearray()
        while True:
            size_line = stream.readline().strip()
            if not size_line:
                break
            chunk_size = int(size_line.split(b";", 1)[0], 16)
            if chunk_size == 0:
                stream.readline()
                break
            chunks.extend(stream.read(chunk_size))
            stream.read(2)
        return bytes(chunks).decode("utf-8", errors="replace")

    try:
        content_length = int(headers.get("Content-Length", "0"))
    except ValueError:
        content_length = 0
    return stream.read(content_length).decode("utf-8", errors="replace")


def _fingerprint(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()[:16]


def main() -> None:
    parser = argparse.ArgumentParser(description="Milestone 19-5 auth fixture")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=18443)
    parser.add_argument("--evidence", type=Path)
    parser.add_argument("--cert", type=Path, required=True)
    parser.add_argument("--key", type=Path, required=True)
    args = parser.parse_args()

    state = AuthFixtureState(args.evidence)
    server = AuthFixtureHttpServer((args.host, args.port), state)
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.load_cert_chain(certfile=args.cert, keyfile=args.key)
    server.socket = context.wrap_socket(server.socket, server_side=True)
    print(json.dumps({"event": "listening", "host": args.host, "port": args.port}))
    server.serve_forever()


if __name__ == "__main__":
    main()
