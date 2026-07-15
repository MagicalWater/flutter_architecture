import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AuthSession 可以保存 token 與使用者資訊', () {
    const session = AuthSession(
      accessToken: 'mock-access-token',
      userId: 'user-001',
      generation: 1,
    );

    expect(session.accessToken, isNotEmpty);
    expect(session.userId, 'user-001');
  });

  test('LoginResponseDto mapper 會轉為 AuthResult', () {
    const dto = LoginResponseDto(
      accessToken: 'token',
      refreshToken: 'refresh-token',
      userId: 'user-001',
      userName: 'Water Magical',
    );

    final result = dto.toDomain();

    expect(result.accessToken, 'token');
    expect(result.refreshToken, 'refresh-token');
    expect(result.user.id, 'user-001');
    expect(result.user.name, 'Water Magical');
  });

  test('StoredAuthTokens 可以用單一 JSON payload 往返', () {
    const tokens = StoredAuthTokens(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );

    final restored = StoredAuthTokens.fromJson(tokens.toJson());

    expect(restored.accessToken, tokens.accessToken);
    expect(restored.refreshToken, tokens.refreshToken);
  });

  test('Session generation 在建立與清除 Session 時遞增，更新 token 時保持不變', () {
    final manager = SessionManager();

    manager.setAuthenticated(accessToken: 'token-1', userId: 'user-001');
    final generation = manager.currentSession!.generation;

    manager.updateAccessToken('token-2');
    expect(manager.currentSession!.generation, generation);
    expect(manager.currentSession!.accessToken, 'token-2');

    manager.clear();
    expect(manager.generation, generation + 1);
    expect(manager.currentSession, isNull);
  });

}
