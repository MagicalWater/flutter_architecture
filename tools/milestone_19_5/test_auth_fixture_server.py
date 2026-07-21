import io
import json
import unittest

from auth_fixture_server import (
    ACCESS_V1,
    ACCESS_V2,
    REFRESH_V1,
    AuthFixtureState,
    _read_http_body,
)


class AuthFixtureStateTest(unittest.TestCase):
    def setUp(self) -> None:
        self.state = AuthFixtureState()

    def test_login_profile_401_refresh_replay_sequence(self) -> None:
        login = self.state.login()
        first_profile = self.state.profile(f"Bearer {ACCESS_V1}")
        refresh = self.state.refresh(REFRESH_V1)
        replay = self.state.profile(f"Bearer {ACCESS_V2}")

        self.assertEqual(login.status, 200)
        self.assertEqual(first_profile.status, 401)
        self.assertEqual(refresh.status, 200)
        self.assertEqual(replay.status, 200)
        self.assertEqual(
            [event["path"] for event in self.state.evidence()],
            ["/auth/login", "/profile", "/auth/refresh", "/profile"],
        )
        self.assertEqual(
            [event["status"] for event in self.state.evidence()],
            [200, 401, 200, 200],
        )

    def test_refresh_is_called_once(self) -> None:
        first = self.state.refresh(REFRESH_V1)
        second = self.state.refresh(REFRESH_V1)

        self.assertEqual(first.status, 200)
        self.assertEqual(second.status, 401)
        self.assertEqual(self.state.refresh_count, 1)

    def test_restart_profile_accepts_access_v2_without_refresh(self) -> None:
        self.state.login()
        self.state.profile(f"Bearer {ACCESS_V1}")
        self.state.refresh(REFRESH_V1)

        restarted_profile = self.state.profile(f"Bearer {ACCESS_V2}")

        self.assertEqual(restarted_profile.status, 200)
        self.assertEqual(self.state.refresh_count, 1)

    def test_logs_never_include_raw_credentials_or_request_body(self) -> None:
        raw_body = json.dumps(
            {
                "account": "demo",
                "password": "M19_PASSWORD_SECRET_11de",
            }
        )
        self.state.login(raw_body=raw_body)
        self.state.profile(f"Bearer {ACCESS_V1}")
        self.state.refresh(REFRESH_V1, raw_body=raw_body)

        evidence = json.dumps(self.state.evidence(), ensure_ascii=False)

        for secret in (
            ACCESS_V1,
            ACCESS_V2,
            REFRESH_V1,
            "M19_PASSWORD_SECRET_11de",
            raw_body,
            "Authorization",
            "Bearer ",
        ):
            self.assertNotIn(secret, evidence)

    def test_wrong_refresh_token_returns_401_without_logging_value(self) -> None:
        wrong = "M19_REFRESH_SECRET_WRONG_91af"

        response = self.state.refresh(wrong)
        evidence = json.dumps(self.state.evidence(), ensure_ascii=False)

        self.assertEqual(response.status, 401)
        self.assertNotIn(wrong, evidence)

    def test_reset_clears_sequence_and_refresh_count(self) -> None:
        self.state.login()
        self.state.refresh(REFRESH_V1)

        self.state.reset()

        self.assertEqual(self.state.evidence(), [])
        self.assertEqual(self.state.refresh_count, 0)

    def test_chunked_request_body_is_decoded(self) -> None:
        payload = b'{"refreshToken":"m19-refresh-v1"}'
        stream = io.BytesIO(
            b'%X\r\n' % len(payload) + payload + b'\r\n0\r\n\r\n'
        )

        body = _read_http_body(
            stream,
            {
                "Transfer-Encoding": "chunked",
            },
        )

        self.assertEqual(body, payload.decode("utf-8"))


if __name__ == "__main__":
    unittest.main()
