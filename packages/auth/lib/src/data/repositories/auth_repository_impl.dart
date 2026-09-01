import 'package:api_client/api_client.dart';
import 'package:auth/src/data/data_sources/auth_remote_data_source.dart';
import 'package:auth/src/data/mappers/login_response_dto_mapper.dart';
import 'package:auth/src/data/mappers/otp_challenge_dto_mapper.dart';
import 'package:auth/src/data/lifecycle/auth_lifecycle_diagnostic.dart';
import 'package:auth/src/data/lifecycle/auth_lifecycle_diagnostic_sink.dart';
import 'package:auth/src/data/lifecycle/auth_lifecycle_cleanup_policy.dart';
import 'package:auth/src/data/migration/auth_credential_migration_coordinator.dart';
import 'package:auth/src/data/migration/auth_credential_migration_result.dart';
import 'package:auth/src/data/models/stored_auth_tokens.dart';
import 'package:auth/src/data/stores/auth_credential_store.dart';
import 'package:auth/src/data/stores/auth_legacy_credential_store.dart';
import 'package:auth/src/data/stores/auth_user_store.dart';
import 'package:auth/src/domain/entities/auth_result.dart';
import 'package:auth/src/domain/entities/auth_authenticated_result.dart';
import 'package:auth/src/domain/entities/otp_challenge.dart';
import 'package:auth/src/domain/entities/auth_user.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:auth/src/local_unlock/local_unlock_preference.dart';
import 'package:auth/src/session/session_manager.dart';
import 'package:auth/src/session/auth_state_mutation_coordinator.dart';
import 'package:core/core.dart';

/// AuthRepository 的 Data Layer 實作。
///
/// ## Runtime Flow
///
/// ```txt
/// AuthRepository
///   ↓
/// AuthRepositoryImpl
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
    this._migrationCoordinator,
    this._diagnosticSink, [
    this._localUnlockPreferenceStore,
  ]);

  final AuthRemoteDataSource _remoteDataSource;
  final AuthCredentialStore _credentialStore;
  final AuthLegacyCredentialStore _legacyCredentialStore;
  final AuthUserStore _userStore;
  final SessionManager _sessionManager;
  final AuthStateMutationCoordinator _mutationCoordinator;
  final AuthCredentialMigrationCoordinator _migrationCoordinator;
  final AuthLifecycleDiagnosticSink _diagnosticSink;
  final LocalUnlockPreferenceStore? _localUnlockPreferenceStore;

  @override
  Future<Result<AuthLoginResult>> login({
    required String account,
    required String password,
  }) async {
    final operation = _mutationCoordinator.beginLifecycleOperation();
    try {
      final response = await _remoteDataSource.login(
        account: account,
        password: password,
      );

      final result = _mapLoginResponse(response);

      if (result is AuthLoginAuthenticated) {
        await _mutationCoordinator.runExclusive(() async {
          operation.throwIfSuperseded();
          await _commitAuthenticatedUnlocked(operation, result.result);
        });
      } else {
        operation.throwIfSuperseded();
      }

      return SuccessResult(result);
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
  Future<Result<AuthAuthenticatedResult>> verifyOtp({
    required String challengeId,
    required String code,
  }) async {
    final operation = _mutationCoordinator.beginLifecycleOperation();
    try {
      final response = await _remoteDataSource.verifyOtp(
        challengeId: challengeId,
        code: code,
      );
      final result = _mapAuthenticatedResponse(response);
      await _mutationCoordinator.runExclusive(() async {
        operation.throwIfSuperseded();
        await _commitAuthenticatedUnlocked(operation, result);
      });
      return SuccessResult(result);
    } on AppException catch (error) {
      return FailureResult(
        mapAppExceptionToFailure(
          error,
          fallbackMessage: 'OTP verification failed.',
        ),
      );
    }
  }

  @override
  Future<Result<OtpChallenge>> resendOtp({required String challengeId}) async {
    final operation = _mutationCoordinator.beginLifecycleOperation();
    try {
      final response = await _remoteDataSource.resendOtp(
        challengeId: challengeId,
      );
      final challenge = _mapOtpChallenge(response);
      operation.throwIfSuperseded();
      return SuccessResult(challenge);
    } on AppException catch (error) {
      return FailureResult(
        mapAppExceptionToFailure(error, fallbackMessage: 'OTP resend failed.'),
      );
    }
  }

  AuthLoginResult _mapLoginResponse(LoginResponseDto response) {
    try {
      return response.toDomain();
    } on FormatException catch (error, stackTrace) {
      throw _protocolException(error, stackTrace);
    } on ArgumentError catch (error, stackTrace) {
      throw _protocolException(error, stackTrace);
    }
  }

  AuthAuthenticatedResult _mapAuthenticatedResponse(
    AuthenticatedResponseDto response,
  ) {
    try {
      return response.toDomain();
    } on FormatException catch (error, stackTrace) {
      throw _protocolException(error, stackTrace);
    } on ArgumentError catch (error, stackTrace) {
      throw _protocolException(error, stackTrace);
    }
  }

  OtpChallenge _mapOtpChallenge(OtpChallengeDto response) {
    try {
      return response.toDomain();
    } on FormatException catch (error, stackTrace) {
      throw _protocolException(error, stackTrace);
    } on ArgumentError catch (error, stackTrace) {
      throw _protocolException(error, stackTrace);
    }
  }

  AppException _protocolException(Object error, StackTrace stackTrace) =>
      AppException(
        kind: AppExceptionKind.protocol,
        message: 'Invalid OTP authentication response',
        diagnosticCode: 'auth_otp_protocol_violation',
        cause: error,
        stackTrace: stackTrace,
      );

  Future<void> _commitAuthenticatedUnlocked(
    AuthLifecycleOperation operation,
    AuthAuthenticatedResult result,
  ) async {
    final user = result.user;
    try {
      // Authenticated commit 採 persistence-first，且每個 await 後都重新確認
      // lifecycle lease，避免較舊 login / OTP completion 覆蓋較新的使用者意圖。
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
      _sessionManager.setAuthenticated(
        accessToken: result.accessToken,
        userId: user.id,
      );
    } catch (error, stackTrace) {
      // 複合 commit 任一步失敗都要清除已寫入的 partial auth state；cleanup
      // 本身的 unexpected failure 不可被原始 local-storage error 吞掉。
      final cleanup = await AuthLifecycleCleanupPolicy(
        secureCredentialStore: _credentialStore,
        legacyCredentialStore: _legacyCredentialStore,
        userStore: _userStore,
        localUnlockPreferenceStore: _localUnlockPreferenceStore,
      ).clearAllUnlocked();
      cleanup.throwIfUnexpected();
      if (error is AuthLifecycleOperationSuperseded) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      _sessionManager.clear();
      if (!_isExpectedLocalStorage(error)) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      cleanup.throwIfFailed();
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  bool _isExpectedLocalStorage(Object error) {
    return error is AppException && error.kind == AppExceptionKind.localStorage;
  }

  @override
  Future<Result<AuthUser?>> restoreSession() async {
    final operation = _mutationCoordinator.beginLifecycleOperation();
    try {
      // Restore 的 durable authority resolution 與 runtime Session commit 必須位於同一
      // exclusive mutation window；否則 login/logout 可插入兩者之間造成跨 lifecycle commit。
      final outcome = await _mutationCoordinator.runExclusive(() async {
        operation.throwIfSuperseded();
        final resolution = await _resolveRestoreUnlocked();
        operation.throwIfSuperseded();

        if (resolution is AuthCredentialMigrationUnauthenticated) {
          await _clearStaleLocalUnlockPreferenceBestEffort();
          _sessionManager.clear();
          return _AuthRestoreOutcome(
            user: null,
            diagnostics: resolution.diagnostics,
          );
        }

        final resolved = resolution as AuthCredentialMigrationResolved;
        operation.throwIfSuperseded();

        // 只有 migration coordinator 已解析出一致的 credential + user authority，
        // 且 lease 仍為 current，才允許建立 runtime authenticated Session。
        _sessionManager.setAuthenticated(
          accessToken: resolved.tokens.accessToken,
          userId: resolved.user.id,
        );

        return _AuthRestoreOutcome(
          user: resolved.user,
          diagnostics: resolved.diagnostics,
        );
      });
      _reportDiagnosticsBestEffort(outcome.diagnostics);
      return SuccessResult(outcome.user);
    } on AppException catch (error, stackTrace) {
      if (error.kind != AppExceptionKind.localStorage &&
          error.kind != AppExceptionKind.dataCorruption) {
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

  void _reportDiagnosticsBestEffort(
    Iterable<AuthLifecycleDiagnostic> diagnostics,
  ) {
    try {
      _diagnosticSink.reportAll(diagnostics);
    } on Object {
      // Reporting不得改變合法restore結果。
    }
  }

  Future<AuthCredentialMigrationResult> _resolveRestoreUnlocked() {
    return _migrationCoordinator.resolveUnlocked();
  }

  @override
  Future<Result<void>> logout() async {
    final operation = _mutationCoordinator.beginLifecycleOperation();
    try {
      await _mutationCoordinator.runExclusive(() async {
        operation.throwIfSuperseded();
        // Logout cleanup 先嘗試移除所有 durable auth state，再由仍持有最新
        // lifecycle lease 的 operation clear runtime Session。
        final cleanup = await AuthLifecycleCleanupPolicy(
          secureCredentialStore: _credentialStore,
          legacyCredentialStore: _legacyCredentialStore,
          userStore: _userStore,
          localUnlockPreferenceStore: _localUnlockPreferenceStore,
        ).clearAllUnlocked();
        if (operation.isCurrent) {
          _sessionManager.clear();
        }
        cleanup.throwIfUnexpected();
        operation.throwIfSuperseded();
        cleanup.throwIfFailed();
      });
      return const SuccessResult(null);
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

  Future<void> _clearStaleLocalUnlockPreferenceBestEffort() async {
    final store = _localUnlockPreferenceStore;
    if (store == null) return;
    try {
      await store.clear();
    } on AppException catch (error) {
      if (error.kind != AppExceptionKind.localStorage) rethrow;
    }
  }
}

final class _AuthRestoreOutcome {
  const _AuthRestoreOutcome({required this.user, required this.diagnostics});

  final AuthUser? user;
  final List<AuthLifecycleDiagnostic> diagnostics;
}
