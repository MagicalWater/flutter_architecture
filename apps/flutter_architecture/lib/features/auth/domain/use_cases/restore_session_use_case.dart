import 'package:core/core.dart';
import 'package:flutter_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

/// 嘗試從本地資料恢復登入狀態。
///
/// ## 典型使用時機
///
/// App 啟動時，AuthBloc 會呼叫這個 UseCase。
///
/// 如果本地已有 token 與 profile，就可以自動登入。
@injectable
class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser?>> execute() {
    return _repository.restoreSession();
  }
}
