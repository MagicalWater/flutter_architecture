import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:auth/src/data/data_sources/auth_refresh_remote_data_source.dart';
import 'package:auth/src/data/exceptions/invalid_refresh_credential_exception.dart';
import 'package:auth/src/data/exceptions/temporary_refresh_exception.dart';
import 'package:auth/src/data/lifecycle/auth_lifecycle_cleanup_policy.dart';
import 'package:auth/src/data/lifecycle/auth_lifecycle_diagnostic.dart';
import 'package:auth/src/data/lifecycle/auth_lifecycle_diagnostic_sink.dart';
import 'package:auth/src/data/models/stored_auth_tokens.dart';
import 'package:auth/src/data/stores/auth_credential_read_result.dart';
import 'package:auth/src/data/stores/auth_credential_store.dart';
import 'package:auth/src/data/stores/auth_legacy_credential_store.dart';
import 'package:auth/src/data/stores/auth_user_store.dart';
import 'package:auth/src/session/session_manager.dart';
import 'package:auth/src/session/auth_state_mutation_coordinator.dart';
import 'package:core/core.dart';

class AuthSessionRefresher implements AuthRefresher {
  AuthSessionRefresher(
    this._remoteDataSource,
    this._credentialStore,
    this._legacyCredentialStore,
    this._userStore,
    this._sessionManager,
    this._mutationCoordinator,
  );

  factory AuthSessionRefresher.secureLifecycle(
    AuthRefreshRemoteDataSource remoteDataSource,
    AuthCredentialStore credentialStore,
    AuthLegacyCredentialStore legacyCredentialStore,
    AuthUserStore userStore,
    SessionManager sessionManager,
    AuthStateMutationCoordinator mutationCoordinator,
    AuthLifecycleDiagnosticSink diagnosticSink,
  ) = _SecureLifecycleAuthSessionRefresher;

  final AuthRefreshRemoteDataSource _remoteDataSource;
  final AuthCredentialStore _credentialStore;
  final AuthLegacyCredentialStore _legacyCredentialStore;
  final AuthUserStore _userStore;
  final SessionManager _sessionManager;
  final AuthStateMutationCoordinator _mutationCoordinator;

  _InFlightRefresh? _inFlight;

  @override
  Future<AuthRefreshResult> refresh({required String failedAccessToken}) async {
    final session = _sessionManager.currentSession;
    if (session == null) {
      return const AuthRefreshSessionChanged();
    }
    if (session.accessToken != failedAccessToken) {
      return const AuthRefreshSuccess();
    }

    final existing = _inFlight;
    if (existing != null) {
      if (existing.matches(
        generation: session.generation,
        userId: session.userId,
        failedAccessToken: failedAccessToken,
      )) {
        return existing.future;
      }
      await existing.future;
      return refresh(failedAccessToken: failedAccessToken);
    }

    final completer = Completer<AuthRefreshResult>();
    final operation = completer.future;
    final inFlight = _InFlightRefresh(
      generation: session.generation,
      userId: session.userId,
      failedAccessToken: failedAccessToken,
      future: operation,
    );
    _inFlight = inFlight;
    _completeRefresh(inFlight: inFlight, completer: completer);
    return operation;
  }

  Future<void> _completeRefresh({
    required _InFlightRefresh inFlight,
    required Completer<AuthRefreshResult> completer,
  }) async {
    try {
      completer.complete(await _performRefresh(inFlight));
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
    } finally {
      if (identical(_inFlight, inFlight)) {
        _inFlight = null;
      }
    }
  }

  Future<AuthRefreshResult> _performRefresh(_InFlightRefresh inFlight) async {
    late final StoredAuthTokens tokens;
    try {
      final stored = await _mutationCoordinator.runExclusive(() async {
        if (!_isSameSession(inFlight.generation, inFlight.userId)) {
          return null;
        }
        final credential = await _credentialStore.readCredential();
        if (credential is! AuthCredentialReadPresent) {
          return null;
        }
        final tokens = credential.tokens;
        if (tokens.userId == null ||
            tokens.userId != inFlight.userId ||
            tokens.isRefreshTokenExpired) {
          return null;
        }
        final user = await _userStore.readUser();
        if (user == null || user.id != inFlight.userId) {
          return null;
        }
        return tokens;
      });
      if (!_isSameSession(inFlight.generation, inFlight.userId)) {
        return const AuthRefreshSessionChanged();
      }
      if (stored == null) {
        final invalidated = await _invalidateSessionBestEffort(
          generation: inFlight.generation,
          userId: inFlight.userId,
        );
        return invalidated
            ? const AuthRefreshSessionExpired()
            : const AuthRefreshSessionChanged();
      }
      tokens = stored;
    } on AppException catch (error, stackTrace) {
      if (error.kind != AppExceptionKind.localStorage) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      return _isSameSession(inFlight.generation, inFlight.userId)
          ? const AuthRefreshLocalStateFailure()
          : const AuthRefreshSessionChanged();
    }

    try {
      final response = await _remoteDataSource.refresh(tokens.refreshToken);
      return _mutationCoordinator.runExclusive(() async {
        if (!_isSameSession(inFlight.generation, inFlight.userId)) {
          return const AuthRefreshSessionChanged();
        }

        try {
          await _credentialStore.writeCredential(
            StoredAuthTokens(
              accessToken: response.accessToken,
              refreshToken: response.refreshToken,
              userId: inFlight.userId,
              accessTokenExpiresAt: response.accessTokenExpiresAt,
              refreshTokenExpiresAt: response.refreshTokenExpiresAt,
            ),
          );
        } on AppException catch (error, stackTrace) {
          if (error.kind != AppExceptionKind.localStorage) {
            Error.throwWithStackTrace(error, stackTrace);
          }
          await _invalidateSessionBestEffortUnlocked();
          return const AuthRefreshLocalStateFailure();
        }

        _sessionManager.updateAccessToken(response.accessToken);
        return const AuthRefreshSuccess();
      });
    } on InvalidRefreshCredentialException {
      final invalidated = await _invalidateSessionBestEffort(
        generation: inFlight.generation,
        userId: inFlight.userId,
      );
      return invalidated
          ? const AuthRefreshSessionExpired()
          : const AuthRefreshSessionChanged();
    } on TemporaryRefreshException {
      return const AuthRefreshTemporarilyUnavailable();
    }
  }

  bool _isSameSession(int generation, String userId) {
    final current = _sessionManager.currentSession;
    return current != null &&
        current.generation == generation &&
        current.userId == userId;
  }

  Future<bool> _invalidateSessionBestEffort({
    required int generation,
    required String userId,
  }) async {
    return _mutationCoordinator.runExclusive(() async {
      if (!_isSameSession(generation, userId)) {
        return false;
      }
      await _invalidateSessionBestEffortUnlocked();
      return true;
    });
  }

  Future<void> _invalidateSessionBestEffortUnlocked() async {
    try {
      await _credentialStore.clearCredential();
    } catch (_) {}
    try {
      await _legacyCredentialStore.clearLegacyCredential();
    } catch (_) {}
    try {
      await _userStore.clearUser();
    } catch (_) {}
    _sessionManager.clear();
  }
}

final class _SecureLifecycleAuthSessionRefresher extends AuthSessionRefresher {
  _SecureLifecycleAuthSessionRefresher(
    super.remoteDataSource,
    super.credentialStore,
    super.legacyCredentialStore,
    super.userStore,
    super.sessionManager,
    super.mutationCoordinator,
    this._diagnosticSink,
  );

  final AuthLifecycleDiagnosticSink _diagnosticSink;

  @override
  Future<AuthRefreshResult> _performRefresh(_InFlightRefresh inFlight) async {
    late final StoredAuthTokens tokens;
    try {
      final stored = await _mutationCoordinator.runExclusive(() async {
        if (!_isSameSession(inFlight.generation, inFlight.userId)) return null;
        final credential = await _credentialStore.readCredential();
        if (credential is! AuthCredentialReadPresent) return null;
        final resolved = credential.tokens;
        if (resolved.userId == null ||
            resolved.userId != inFlight.userId ||
            resolved.isRefreshTokenExpired) {
          return null;
        }
        final user = await _userStore.readUser();
        if (user == null || user.id != inFlight.userId) return null;
        return resolved;
      });
      if (!_isSameSession(inFlight.generation, inFlight.userId)) {
        return const AuthRefreshSessionChanged();
      }
      if (stored == null) {
        return _invalidateSecureSession(
          generation: inFlight.generation,
          userId: inFlight.userId,
          expiredResult: const AuthRefreshSessionExpired(),
        );
      }
      tokens = stored;
    } on AppException catch (error, stackTrace) {
      if (error.kind != AppExceptionKind.localStorage) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      return _isSameSession(inFlight.generation, inFlight.userId)
          ? const AuthRefreshLocalStateFailure()
          : const AuthRefreshSessionChanged();
    }

    try {
      final response = await _remoteDataSource.refresh(tokens.refreshToken);
      final outcome = await _mutationCoordinator.runExclusive(() async {
        if (!_isSameSession(inFlight.generation, inFlight.userId)) {
          return const _SecureRefreshOutcome(
            result: AuthRefreshSessionChanged(),
          );
        }
        try {
          await _credentialStore.writeCredential(
            StoredAuthTokens(
              accessToken: response.accessToken,
              refreshToken: response.refreshToken,
              userId: inFlight.userId,
              accessTokenExpiresAt: response.accessTokenExpiresAt,
              refreshTokenExpiresAt: response.refreshTokenExpiresAt,
            ),
          );
        } on AppException catch (error, stackTrace) {
          if (error.kind != AppExceptionKind.localStorage) {
            Error.throwWithStackTrace(error, stackTrace);
          }
          final cleanup = await _clearSecureAuthStateUnlocked();
          _sessionManager.clear();
          return _SecureRefreshOutcome(
            result: const AuthRefreshLocalStateFailure(),
            cleanup: cleanup,
          );
        }
        _sessionManager.updateAccessToken(response.accessToken);
        return const _SecureRefreshOutcome(result: AuthRefreshSuccess());
      });
      return _completeOutcome(outcome);
    } on InvalidRefreshCredentialException {
      return _invalidateSecureSession(
        generation: inFlight.generation,
        userId: inFlight.userId,
        expiredResult: const AuthRefreshSessionExpired(),
      );
    } on TemporaryRefreshException {
      return const AuthRefreshTemporarilyUnavailable();
    }
  }

  Future<AuthRefreshResult> _invalidateSecureSession({
    required int generation,
    required String userId,
    required AuthRefreshResult expiredResult,
  }) async {
    final outcome = await _mutationCoordinator.runExclusive(() async {
      if (!_isSameSession(generation, userId)) {
        return const _SecureRefreshOutcome(result: AuthRefreshSessionChanged());
      }
      final cleanup = await _clearSecureAuthStateUnlocked();
      _sessionManager.clear();
      return _SecureRefreshOutcome(result: expiredResult, cleanup: cleanup);
    });
    return _completeOutcome(outcome);
  }

  Future<AuthLifecycleCleanupResult> _clearSecureAuthStateUnlocked() {
    return AuthLifecycleCleanupPolicy(
      secureCredentialStore: _credentialStore,
      legacyCredentialStore: _legacyCredentialStore,
      userStore: _userStore,
    ).clearAllUnlocked();
  }

  AuthRefreshResult _completeOutcome(_SecureRefreshOutcome outcome) {
    final cleanup = outcome.cleanup;
    if (cleanup == null) return outcome.result;
    _reportExpectedBestEffort(cleanup.diagnostics);
    cleanup.throwIfUnexpected();
    return outcome.result;
  }

  void _reportExpectedBestEffort(
    Iterable<AuthLifecycleDiagnostic> diagnostics,
  ) {
    final expected = diagnostics.where((diagnostic) {
      final error = diagnostic.error;
      return error is AppException &&
          error.kind == AppExceptionKind.localStorage;
    });
    try {
      _diagnosticSink.reportAll(expected);
    } on Object {
      // Passive invalidation reporting不得改變Session expiration語意。
    }
  }
}

final class _SecureRefreshOutcome {
  const _SecureRefreshOutcome({required this.result, this.cleanup});

  final AuthRefreshResult result;
  final AuthLifecycleCleanupResult? cleanup;
}

final class _InFlightRefresh {
  const _InFlightRefresh({
    required this.generation,
    required this.userId,
    required this.failedAccessToken,
    required this.future,
  });

  final int generation;
  final String userId;
  final String failedAccessToken;
  final Future<AuthRefreshResult> future;

  bool matches({
    required int generation,
    required String userId,
    required String failedAccessToken,
  }) {
    return this.generation == generation &&
        this.userId == userId &&
        this.failedAccessToken == failedAccessToken;
  }
}
