import 'package:auth/src/data/data_sources/auth_remote_data_source.dart';
import 'package:auth/src/data/mappers/login_response_dto_mapper.dart';
import 'package:auth/src/data/models/stored_auth_tokens.dart';
import 'package:auth/src/data/stores/auth_credential_read_result.dart';
import 'package:auth/src/data/stores/auth_credential_store.dart';
import 'package:auth/src/data/stores/auth_legacy_credential_store.dart';
import 'package:auth/src/data/stores/auth_user_store.dart';
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
    this._credentialStore,
    this._legacyCredentialStore,
    this._userStore,
    this._sessionManager,
    this._mutationCoordinator,
  );

  final AuthRemoteDataSource _remoteDataSource;
  final AuthCredentialStore _credentialStore;
  final AuthLegacyCredentialStore _legacyCredentialStore;
  final AuthUserStore _userStore;
  final SessionManager _sessionManager;
  final AuthStateMutationCoordinator _mutationCoordinator;

  @override
  Future<Result<AuthResult>> login({
    required String account,
    required String password,
  }) async {
    final operation = _mutationCoordinator.beginLifecycleOperation();
    try {
      final response = await _remoteDataSource.login(
        account: account,
        password: password,
      );

      final result = response.toDomain();
      final user = result.user;

      await _mutationCoordinator.runExclusive(() async {
        operation.throwIfSuperseded();
        try {
          await _credentialStore.writeCredential(
            StoredAuthTokens(
              accessToken: result.accessToken,
              refreshToken: result.refreshToken,
              userId: user.id,
            ),
          );
          operation.throwIfSuperseded();
          await _userStore.writeUser(user);
          operation.throwIfSuperseded();
        } catch (error, stackTrace) {
          if (error is AuthLifecycleOperationSuperseded) {
            await _clearLocalAuthStateBestEffort();
            Error.throwWithStackTrace(error, stackTrace);
          }
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
    final operation = _mutationCoordinator.beginLifecycleOperation();
    try {
      return await _mutationCoordinator.runExclusive(() async {
        operation.throwIfSuperseded();
        final credential = await _credentialStore.readCredential();
        operation.throwIfSuperseded();

        if (credential is AuthCredentialReadAbsent ||
            credential is AuthCredentialReadCorrupted) {
          await _clearLocalAuthStateBestEffort();
          _sessionManager.clear();
          return const Success(null);
        }

        final user = await _userStore.readUser();
        operation.throwIfSuperseded();
        if (user == null) {
          await _clearLocalAuthStateBestEffort();
          _sessionManager.clear();
          return const Success(null);
        }

        final tokens = (credential as AuthCredentialReadPresent).tokens;
        if (tokens.userId == null || tokens.userId != user.id) {
          await _clearLocalAuthStateBestEffort();
          _sessionManager.clear();
          return const Success(null);
        }

        _sessionManager.setAuthenticated(
          accessToken: tokens.accessToken,
          userId: user.id,
        );

        return Success(user);
      });
    } on AppException catch (error, stackTrace) {
      if (error.kind != AppExceptionKind.localStorage) {
        Error.throwWithStackTrace(error, stackTrace);
      }
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
    final operation = _mutationCoordinator.beginLifecycleOperation();
    try {
      await _mutationCoordinator.runExclusive(() async {
        operation.throwIfSuperseded();
        Object? expectedError;
        StackTrace? expectedStackTrace;
        Object? unexpectedError;
        StackTrace? unexpectedStackTrace;

        void captureError(Object error, StackTrace stackTrace) {
          if (error is AppException &&
              error.kind == AppExceptionKind.localStorage) {
            expectedError ??= error;
            expectedStackTrace ??= stackTrace;
            return;
          }
          unexpectedError ??= error;
          unexpectedStackTrace ??= stackTrace;
        }

        try {
          await _userStore.clearUser();
        } catch (error, stackTrace) {
          captureError(error, stackTrace);
        }
        try {
          await _credentialStore.clearCredential();
        } catch (error, stackTrace) {
          captureError(error, stackTrace);
        }
        try {
          await _legacyCredentialStore.clearLegacyCredential();
        } catch (error, stackTrace) {
          captureError(error, stackTrace);
        } finally {
          if (operation.isCurrent) {
            _sessionManager.clear();
          }
        }
        final capturedUnexpectedError = unexpectedError;
        if (capturedUnexpectedError != null) {
          Error.throwWithStackTrace(
            capturedUnexpectedError,
            unexpectedStackTrace!,
          );
        }
        operation.throwIfSuperseded();
        final capturedExpectedError = expectedError;
        if (capturedExpectedError != null) {
          Error.throwWithStackTrace(capturedExpectedError, expectedStackTrace!);
        }
      });
      return const Success(null);
    } on AppException catch (error, stackTrace) {
      if (error.kind != AppExceptionKind.localStorage) {
        Error.throwWithStackTrace(error, stackTrace);
      }
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
      await _credentialStore.clearCredential();
    } catch (_) {}
    try {
      await _legacyCredentialStore.clearLegacyCredential();
    } catch (_) {}
    try {
      await _userStore.clearUser();
    } catch (_) {}
  }
}
