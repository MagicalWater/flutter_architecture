import 'package:auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

const _accessSentinel = 'M19_ACCESS_SECRET_7f4a';
const _refreshSentinel = 'M19_REFRESH_SECRET_2c91';
const _passwordSentinel = 'M19_PASSWORD_SECRET_11de';
const _pluginSentinel = 'M19_PLUGIN_SECRET_a63b';

void main() {
  test('credential read result exposes closed typed variants safely', () {
    const tokens = StoredAuthTokens(
      accessToken: 'access-secret',
      refreshToken: 'refresh-secret',
      userId: 'user-001',
    );

    const absent = AuthCredentialReadAbsent();
    const corrupted = AuthCredentialReadCorrupted();
    const present = AuthCredentialReadPresent(tokens);

    expect(absent, isA<AuthCredentialReadResult>());
    expect(corrupted, isA<AuthCredentialReadResult>());
    expect(present.tokens, same(tokens));
    expect(present.toString(), 'AuthCredentialReadPresent()');
    expect(present.toString(), isNot(contains(tokens.accessToken)));
    expect(present.toString(), isNot(contains(tokens.refreshToken)));
    expect(present.toString(), isNot(contains(tokens.userId!)));
  });

  test('stored tokens and read result hide unified credential sentinels', () {
    const tokens = StoredAuthTokens(
      accessToken: _accessSentinel,
      refreshToken: _refreshSentinel,
      userId: _passwordSentinel,
    );
    const result = AuthCredentialReadPresent(tokens);

    for (final value in <Object>[tokens, result]) {
      _expectNoCredentialSentinel(value.toString());
    }
  });

  test('persistence store contracts use auth-specific public types', () {
    expect(_CredentialStore(), isA<AuthCredentialStore>());
    expect(_LegacyCredentialStore(), isA<AuthLegacyCredentialStore>());
    expect(_UserStore(), isA<AuthUserStore>());
  });
}

void _expectNoCredentialSentinel(String text) {
  expect(text, isNot(contains(_accessSentinel)));
  expect(text, isNot(contains(_refreshSentinel)));
  expect(text, isNot(contains(_passwordSentinel)));
  expect(text, isNot(contains(_pluginSentinel)));
}

final class _CredentialStore implements AuthCredentialStore {
  @override
  Future<void> clearCredential() async {}

  @override
  Future<AuthCredentialReadResult> readCredential() async {
    return const AuthCredentialReadAbsent();
  }

  @override
  Future<void> writeCredential(StoredAuthTokens tokens) async {}
}

final class _LegacyCredentialStore implements AuthLegacyCredentialStore {
  @override
  Future<void> clearLegacyCredential() async {}

  @override
  Future<AuthCredentialReadResult> readLegacyCredential() async {
    return const AuthCredentialReadAbsent();
  }
}

final class _UserStore implements AuthUserStore {
  @override
  Future<void> clearUser() async {}

  @override
  Future<AuthUser?> readUser() async => null;

  @override
  Future<void> writeUser(AuthUser user) async {}
}
