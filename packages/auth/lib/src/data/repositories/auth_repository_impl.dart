import 'package:auth/src/data/data_sources/auth_local_store.dart';
import 'package:auth/src/data/data_sources/auth_remote_data_source.dart';
import 'package:auth/src/data/exceptions/corrupted_auth_tokens_exception.dart';
import 'package:auth/src/data/mappers/login_response_dto_mapper.dart';
import 'package:auth/src/data/models/auth_user_model.dart';
import 'package:auth/src/data/models/stored_auth_tokens.dart';
import 'package:auth/src/domain/entities/auth_result.dart';
import 'package:auth/src/domain/entities/auth_user.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:auth/src/session/session_manager.dart';
import 'package:auth/src/session/auth_state_mutation_coordinator.dart';
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
    this._mutationCoordinator,
  );

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalStore _localDataSource;
  final SessionManager _sessionManager;
  final AuthStateMutationCoordinator _mutationCoordinator;

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

      await _mutationCoordinator.runExclusive(() async {
        try {
          await _localDataSource.saveTokens(
            StoredAuthTokens(
              accessToken: result.accessToken,
              refreshToken: result.refreshToken,
            ),
          );
          await _localDataSource.saveUser(AuthUserModel.fromEntity(user));
        } catch (error, stackTrace) {
          await _clearLocalAuthStateBestEffort();
          _sessionManager.clear();
          Error.throwWithStackTrace(error, stackTrace);
        }
        _sessionManager.setAuthenticated(
          accessToken: result.accessToken,
          userId: user.id,
        );
      });

      return Success(result);
    } on AppException catch (error) {
      return FailureResult(
        mapAppExceptionToFailure(
          error,
          fallbackMessage: 'Authentication login failed.',
        ),
      );
    }
  }

  @override
  Future<Result<AuthUser?>> restoreSession() async {
    try {
      return await _mutationCoordinator.runExclusive(() async {
        final tokens = await _localDataSource.readTokens();
        final user = await _localDataSource.readUser();

        if (tokens == null || user == null) {
          await _clearLocalAuthStateBestEffort();
          _sessionManager.clear();
          return const Success(null);
        }

        _sessionManager.setAuthenticated(
          accessToken: tokens.accessToken,
          userId: user.id,
        );

        return Success(user.toEntity());
      });
    } on CorruptedAuthTokensException {
      await _mutationCoordinator.runExclusive(() async {
        await _clearLocalAuthStateBestEffort();
        _sessionManager.clear();
      });
      return const Success(null);
    } on AppException catch (error) {
      return FailureResult(
        mapAppExceptionToFailure(
          error,
          fallbackMessage: 'Authentication session restore failed.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _mutationCoordinator.runExclusive(() async {
        Object? firstError;
        StackTrace? firstStackTrace;
        try {
          await _localDataSource.clearUser();
        } catch (error, stackTrace) {
          firstError = error;
          firstStackTrace = stackTrace;
        }
        try {
          await _localDataSource.clearTokens();
        } catch (error, stackTrace) {
          firstError ??= error;
          firstStackTrace ??= stackTrace;
        } finally {
          _sessionManager.clear();
        }
        if (firstError != null) {
          Error.throwWithStackTrace(firstError, firstStackTrace!);
        }
      });
      return const Success(null);
    } on AppException catch (error) {
      return FailureResult(
        mapAppExceptionToFailure(
          error,
          fallbackMessage: 'Authentication logout failed.',
        ),
      );
    }
  }

  Future<void> _clearLocalAuthStateBestEffort() async {
    try {
      await _localDataSource.clearTokens();
    } catch (_) {}
    try {
      await _localDataSource.clearUser();
    } catch (_) {}
  }
}
