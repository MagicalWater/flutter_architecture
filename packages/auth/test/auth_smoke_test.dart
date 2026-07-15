import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AuthSession 可以保存 token 與使用者資訊', () {
    const session = AuthSession(
      accessToken: 'mock-access-token',
      userId: 'user-001',
    );

    expect(session.accessToken, isNotEmpty);
    expect(session.userId, 'user-001');
  });

  test('LoginResponseDto mapper 會轉為 AuthResult', () {
    const dto = LoginResponseDto(
      accessToken: 'token',
      userId: 'user-001',
      userName: 'Water Magical',
    );

    final result = dto.toDomain();

    expect(result.accessToken, 'token');
    expect(result.user.id, 'user-001');
    expect(result.user.name, 'Water Magical');
  });

}
