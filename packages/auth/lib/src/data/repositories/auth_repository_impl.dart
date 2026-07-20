import 'package:auth/src/data/data_sources/auth_remote_data_source.dart';
import 'package:auth/src/data/mappers/login_response_dto_mapper.dart';
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
    this._migrationCoordinator,
    this._diagnosticSink,
  );

  final AuthRemoteDataSource _remoteDataSource;
  final AuthCredentialStore _credentialStore;
  final AuthLegacyCredentialStore _legacyCredentialStore;
  final AuthUserStore _userStore;
  final SessionManager _sessionManager;
  final AuthStateMutationCoordinator _mutationCoordinator;
  final AuthCredentialMigrationCoordinator _migrationCoordinator;
  final AuthLifecycleDiagnosticSink _diagnosticSink;

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
        await _persistLoginUnlocked(operation, result, user);
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

  Future<void> _persistLoginUnlocked(
    AuthLifecycleOperation operation,
    AuthResult result,
    AuthUser user,
  ) async {
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
      final cleanup = await AuthLifecycleCleanupPolicy(
        secureCredentialStore: _credentialStore,
        legacyCredentialStore: _legacyCredentialStore,
        userStore: _userStore,
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
      final outcome = await _mutationCoordinator.runExclusive(() async {
        operation.throwIfSuperseded();
        final resolution = await _resolveRestoreUnlocked();
        operation.throwIfSuperseded();

        if (resolution is AuthCredentialMigrationUnauthenticated) {
          _sessionManager.clear();
          return _AuthRestoreOutcome(
            user: null,
            diagnostics: resolution.diagnostics,
          );
        }

        final resolved = resolution as AuthCredentialMigrationResolved;
        operation.throwIfSuperseded();

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
      return Success(outcome.user);
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
        final cleanup = await AuthLifecycleCleanupPolicy(
          secureCredentialStore: _credentialStore,
          legacyCredentialStore: _legacyCredentialStore,
          userStore: _userStore,
        ).clearAllUnlocked();
        if (operation.isCurrent) {
          _sessionManager.clear();
        }
        cleanup.throwIfUnexpected();
        operation.throwIfSuperseded();
        cleanup.throwIfFailed();
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
}

final class _AuthRestoreOutcome {
  const _AuthRestoreOutcome({required this.user, required this.diagnostics});

  final AuthUser? user;
  final List<AuthLifecycleDiagnostic> diagnostics;
}
