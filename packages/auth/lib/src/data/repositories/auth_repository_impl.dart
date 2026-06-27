import 'package:auth/src/data/data_sources/auth_local_data_source.dart';
import 'package:auth/src/data/data_sources/auth_remote_data_source.dart';
import 'package:auth/src/data/models/auth_user_model.dart';
import 'package:auth/src/domain/entities/auth_result.dart';
import 'package:auth/src/domain/entities/auth_user.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:auth/src/session/session_manager.dart';
import 'package:core/core.dart';

/// AuthRepository 的 Data Layer 實作。
///
/// ## Runtime Flow
///
/// ```txt
/// LoginUseCase
///   ↓
/// AuthRepository
///   ↓
/// AuthRepositoryImpl  ← 目前所在位置
///   ↓
/// RemoteDataSource / LocalDataSource
/// ```
///
/// RepositoryImpl 負責協調遠端與本地資料來源。
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._sessionManager,
  );

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final SessionManager _sessionManager;

  @override
  Future<Result<AuthResult>> login({
    required String account,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        account: account,
        password: password,
      );

      final user = AuthUser(
        id: response.userId,
        name: response.userName,
      );

      await _localDataSource.saveAccessToken(response.accessToken);
      await _localDataSource.saveUser(AuthUserModel.fromEntity(user));
      await _sessionManager.login(
        accessToken: response.accessToken,
        userId: user.id,
      );

      return Success(
        AuthResult(
          accessToken: response.accessToken,
          user: user,
        ),
      );
    } catch (error) {
      return FailureResult(
        Failure(
          message: '登入失敗',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<AuthUser?>> restoreSession() async {
    try {
      final token = await _localDataSource.readAccessToken();
      final user = await _localDataSource.readUser();

      if (token == null || token.isEmpty || user == null) {
        await _sessionManager.logout();
        return const Success(null);
      }

      await _sessionManager.restore(userId: user.id);

      return Success(user.toEntity());
    } catch (error) {
      return FailureResult(
        Failure(
          message: '恢復登入狀態失敗',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _localDataSource.clearUser();
      await _sessionManager.logout();
      return const Success(null);
    } catch (error) {
      return FailureResult(
        Failure(
          message: '登出失敗',
          cause: error,
        ),
      );
    }
  }
}
