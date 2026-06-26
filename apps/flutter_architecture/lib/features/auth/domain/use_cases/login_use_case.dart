import 'package:core/core.dart';
import 'package:flutter_architecture/features/auth/domain/entities/auth_result.dart';
import 'package:flutter_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

/// 執行登入業務流程。
///
/// ## Runtime Flow
///
/// ```txt
/// LoginPage
///   ↓
/// AuthBloc
///   ↓
/// LoginUseCase  ← 目前所在位置
///   ↓
/// AuthRepository
/// ```
///
/// UseCase 不知道登入是透過 Dio、Firebase、SQLite 還是 Mock API。
/// 它只依賴 Domain Layer 的 Repository 抽象。
@injectable
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthResult>> execute({
    required String account,
    required String password,
  }) {
    return _repository.login(
      account: account,
      password: password,
    );
  }
}
