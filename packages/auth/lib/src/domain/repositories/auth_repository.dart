import 'package:core/core.dart';
import 'package:auth/src/domain/entities/auth_result.dart';
import 'package:auth/src/domain/entities/auth_user.dart';

/// Auth Repository 抽象。
///
/// ## 所屬 Layer
///
/// Domain Layer。
///
/// ## 為什麼放在 Domain？
///
/// UseCase 需要依賴「登入能力」，但不應該依賴 Dio、SQLite、SharedPreferences。
///
/// 所以這裡只定義業務需要的方法，實作放在 Data Layer。
abstract interface class AuthRepository {
  Future<Result<AuthResult>> login({
    required String account,
    required String password,
  });

  Future<Result<AuthUser?>> restoreSession();

  Future<Result<void>> logout();
}
