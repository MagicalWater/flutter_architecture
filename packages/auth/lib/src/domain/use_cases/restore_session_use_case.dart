import 'package:core/core.dart';
import 'package:auth/src/domain/entities/auth_user.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';

/// 嘗試從本地資料恢復登入狀態。
///
/// ## 典型使用時機
///
/// App 啟動時，AuthBloc 會呼叫這個 UseCase。
///
/// Repository 會依 current credential / user authority 決定是否能建立 runtime Session；
/// UseCase 本身不解讀 storage provider 或 migration 細節。
class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser?>> execute() {
    return _repository.restoreSession();
  }
}
