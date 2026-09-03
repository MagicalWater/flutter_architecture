import 'package:auth/src/domain/entities/auth_user.dart';

/// 保存目前登入使用者的基本資料，供 App 重啟後還原 Session 顯示資訊。
///
/// 介面直接使用公開的 [AuthUser]，讓 App 端的 Drift adapter 不需要依賴 package 內部 data model。
abstract interface class AuthUserStore {
  Future<AuthUser?> readUser();

  Future<void> writeUser(AuthUser user);

  Future<void> clearUser();
}
