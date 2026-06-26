import 'package:core/core.dart';
import 'package:flutter_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

/// 執行登出流程。
///
/// 登出不是單純 UI 狀態清空。
///
/// 它需要清除 token、profile cache，以及 session 狀態。
@injectable
class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> execute() {
    return _repository.logout();
  }
}
