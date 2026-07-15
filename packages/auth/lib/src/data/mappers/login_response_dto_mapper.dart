import 'package:api_client/api_client.dart';
import 'package:auth/src/domain/entities/auth_result.dart';
import 'package:auth/src/domain/entities/auth_user.dart';

/// 將 Login API DTO 轉為 Auth Domain Model。
extension LoginResponseDtoMapper on LoginResponseDto {
  AuthResult toDomain() {
    return AuthResult(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: AuthUser(
        id: userId,
        name: userName,
      ),
    );
  }
}
