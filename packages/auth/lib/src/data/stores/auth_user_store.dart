import 'package:auth/src/domain/entities/auth_user.dart';

/// AuthUser persistence boundary。
///
/// 使用公開 Domain entity，避免 App adapter 依賴 package internal data model。
abstract interface class AuthUserStore {
  Future<AuthUser?> readUser();

  Future<void> writeUser(AuthUser user);

  Future<void> clearUser();
}
