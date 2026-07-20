import 'package:auth/src/data/data_sources/auth_remote_data_source.dart';
import 'package:auth/src/data/mappers/login_response_dto_mapper.dart';
import 'package:auth/src/data/lifecycle/auth_lifecycle_diagnostic.dart';
import 'package:auth/src/data/lifecycle/auth_lifecycle_diagnostic_sink.dart';
import 'package:auth/src/data/migration/auth_credential_migration_coordinator.dart';
import 'package:auth/src/data/migration/auth_credential_migration_result.dart';
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

  factory AuthRepositoryImpl.secureLifecycle(
    AuthRemoteDataSource remoteDataSource,
    AuthCredentialStore credentialStore,
    AuthLegacyCredentialStore legacyCredentialStore,
    AuthUserStore userStore,
    SessionManager sessionManager,
    AuthStateMutationCoordinator mutationCoordinator,
    AuthCredentialMigrationCoordinator migrationCoordinator,
    AuthLifecycleDiagnosticSink diagnosticSink,
  ) = _SecureLifecycleAuthRepositoryImpl;

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
  ) {}

  Future<AuthCredentialMigrationResult> _resolveRestoreUnlocked() {
    return _LegacyRestoreResolver(
      _credentialStore,
      _legacyCredentialStore,
      _userStore,
    ).resolveUnlocked();
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

abstract interface class _AuthSessionRestoreResolver {
  Future<AuthCredentialMigrationResult> resolveUnlocked();
}

final class _LegacyRestoreResolver implements _AuthSessionRestoreResolver {
  const _LegacyRestoreResolver(
    this._credentialStore,
    this._legacyCredentialStore,
    this._userStore,
  );

  final AuthCredentialStore _credentialStore;
  final AuthLegacyCredentialStore _legacyCredentialStore;
  final AuthUserStore _userStore;

  @override
  Future<AuthCredentialMigrationResult> resolveUnlocked() async {
    final credential = await _credentialStore.readCredential();
    if (credential is AuthCredentialReadAbsent ||
        credential is AuthCredentialReadCorrupted) {
      await _clearBestEffort();
      return AuthCredentialMigrationUnauthenticated();
    }

    final user = await _userStore.readUser();
    if (user == null) {
      await _clearBestEffort();
      return AuthCredentialMigrationUnauthenticated();
    }

    final tokens = (credential as AuthCredentialReadPresent).tokens;
    if (tokens.userId == null || tokens.userId != user.id) {
      await _clearBestEffort();
      return AuthCredentialMigrationUnauthenticated();
    }

    return AuthCredentialMigrationResolved(tokens: tokens, user: user);
  }

  Future<void> _clearBestEffort() async {
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

final class _AuthRestoreOutcome {
  const _AuthRestoreOutcome({required this.user, required this.diagnostics});

  final AuthUser? user;
  final List<AuthLifecycleDiagnostic> diagnostics;
}

final class _SecureLifecycleAuthRepositoryImpl extends AuthRepositoryImpl {
  const _SecureLifecycleAuthRepositoryImpl(
    super.remoteDataSource,
    super.credentialStore,
    super.legacyCredentialStore,
    super.userStore,
    super.sessionManager,
    super.mutationCoordinator,
    this._migrationCoordinator,
    this._diagnosticSink,
  );

  final AuthCredentialMigrationCoordinator _migrationCoordinator;
  final AuthLifecycleDiagnosticSink _diagnosticSink;

  @override
  Future<AuthCredentialMigrationResult> _resolveRestoreUnlocked() {
    return _migrationCoordinator.resolveUnlocked();
  }

  @override
  void _reportDiagnosticsBestEffort(
    Iterable<AuthLifecycleDiagnostic> diagnostics,
  ) {
    try {
      _diagnosticSink.reportAll(diagnostics);
    } on Object {
      // Reporting不得改變合法restore結果。
    }
  }
}
