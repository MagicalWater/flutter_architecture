import 'package:auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Auth domain result does not expose credentials in toString', () {
    const result = AuthResult(
      accessToken: 'sensitive-access-token',
      refreshToken: 'sensitive-refresh-token',
      user: AuthUser(id: 'user-001', name: 'User'),
    );

    final output = result.toString();

    expect(output, isNot(contains('sensitive-access-token')));
    expect(output, isNot(contains('sensitive-refresh-token')));
  });
}
