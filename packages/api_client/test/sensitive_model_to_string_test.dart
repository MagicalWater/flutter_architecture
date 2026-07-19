import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const accessToken = 'sensitive-access-token';
  const refreshToken = 'sensitive-refresh-token';

  test('Auth transport models do not expose credentials in toString', () {
    final values = <Object>[
      const LoginRequestDto(
        account: 'sensitive-account',
        password: 'sensitive-password',
      ),
      const RefreshTokenRequestDto(refreshToken: refreshToken),
      const LoginResponseDto(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: 'user-001',
        userName: 'User',
      ),
      const RefreshTokenResponseDto(
        accessToken: accessToken,
        refreshToken: refreshToken,
      ),
    ];

    for (final value in values) {
      final output = value.toString();
      expect(output, isNot(contains('sensitive-account')));
      expect(output, isNot(contains('sensitive-password')));
      expect(output, isNot(contains(accessToken)));
      expect(output, isNot(contains(refreshToken)));
    }
  });
}
