import 'package:api_client/api_client.dart';
import 'package:auth/src/domain/entities/auth_result.dart';
import 'package:auth/src/domain/entities/auth_user.dart';

/// 將 Login API DTO 轉為 Auth Domain Model。
extension LoginResponseDtoMapper on LoginResponseDto {
  AuthResult toDomain() {
    return when(
      authenticated: (authenticated) => AuthResult(
        accessToken: authenticated.accessToken,
        refreshToken: authenticated.refreshToken,
        user: AuthUser(id: authenticated.userId, name: authenticated.userName),
      ),
      otpChallenge: (_) => throw StateError(
        'OTP challenge mapping requires Milestone 20-2 domain support.',
      ),
    );
  }
}
