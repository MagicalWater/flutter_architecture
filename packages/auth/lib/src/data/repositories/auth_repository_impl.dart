import 'package:auth/src/data/data_sources/auth_local_data_source.dart';
import 'package:auth/src/data/data_sources/auth_remote_data_source.dart';
import 'package:auth/src/data/mappers/login_response_dto_mapper.dart';
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

      final result = response.toDomain();
      final user = result.user;

      await _localDataSource.saveAccessToken(result.accessToken);
      await _localDataSource.saveUser(AuthUserModel.fromEntity(user));
      _sessionManager.setAuthenticated(
        accessToken: result.accessToken,
        userId: user.id,
      );

      return Success(result);
    } on AppException catch (error) {
      return FailureResult(
        mapAppExceptionToFailure(
          error,
          fallbackMessage: '登入失敗',
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
        _sessionManager.clear();
        return const Success(null);
      }

      _sessionManager.setAuthenticated(
        accessToken: token,
        userId: user.id,
      );

      return Success(user.toEntity());
    } on AppException catch (error) {
      return FailureResult(
        mapAppExceptionToFailure(
          error,
          fallbackMessage: '恢復登入狀態失敗',
        ),
      );
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _localDataSource.clearUser();
      await _localDataSource.clearAccessToken();
      _sessionManager.clear();
      return const Success(null);
    } on AppException catch (error) {
      return FailureResult(
        mapAppExceptionToFailure(
          error,
          fallbackMessage: '登出失敗',
        ),
      );
    }
  }
}
