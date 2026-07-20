import 'package:auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

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
    expect(present.toString(), isNot(contains(tokens.accessToken)));
    expect(present.toString(), isNot(contains(tokens.refreshToken)));
  });

  test('persistence store contracts use auth-specific public types', () {
    expect(_CredentialStore(), isA<AuthCredentialStore>());
    expect(_LegacyCredentialStore(), isA<AuthLegacyCredentialStore>());
    expect(_UserStore(), isA<AuthUserStore>());
  });
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
