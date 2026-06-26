import 'package:auth/auth.dart';
import 'package:test/test.dart';

void main() {
  test('AuthSession 可以保存 token 與使用者資訊', () {
    const session = AuthSession(
      accessToken: 'mock-access-token',
      userId: 'user-001',
    );

    expect(session.accessToken, isNotEmpty);
    expect(session.userId, 'user-001');
  });
}
