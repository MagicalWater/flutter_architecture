import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:auth/src/data/data_sources/auth_refresh_local_store.dart';
import 'package:auth/src/data/data_sources/auth_refresh_remote_data_source.dart';
import 'package:auth/src/data/exceptions/corrupted_auth_tokens_exception.dart';
import 'package:auth/src/data/exceptions/invalid_refresh_credential_exception.dart';
import 'package:auth/src/data/exceptions/temporary_refresh_exception.dart';
import 'package:auth/src/data/models/stored_auth_tokens.dart';
import 'package:auth/src/session/session_manager.dart';
import 'package:auth/src/session/auth_state_mutation_coordinator.dart';

class AuthSessionRefresher implements AuthRefresher {
  AuthSessionRefresher(
    this._remoteDataSource,
    this._localStore,
    this._sessionManager,
    this._mutationCoordinator,
  );

  final AuthRefreshRemoteDataSource _remoteDataSource;
  final AuthRefreshLocalStore _localStore;
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
    _completeRefresh(
      inFlight: inFlight,
      completer: completer,
    );
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
        return _localStore.readTokens();
      });
      if (!_isSameSession(inFlight.generation, inFlight.userId)) {
        return const AuthRefreshSessionChanged();
      }
      if (stored == null || stored.isRefreshTokenExpired) {
        final invalidated = await _invalidateSessionBestEffort(
          generation: inFlight.generation,
          userId: inFlight.userId,
        );
        return invalidated
            ? const AuthRefreshSessionExpired()
            : const AuthRefreshSessionChanged();
      }
      tokens = stored;
    } on CorruptedAuthTokensException {
      final invalidated = await _invalidateSessionBestEffort(
        generation: inFlight.generation,
        userId: inFlight.userId,
      );
      return invalidated
          ? const AuthRefreshSessionExpired()
          : const AuthRefreshSessionChanged();
    } catch (_) {
      final invalidated = await _invalidateSessionBestEffort(
        generation: inFlight.generation,
        userId: inFlight.userId,
      );
      return invalidated
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
          await _localStore.saveTokens(
            StoredAuthTokens(
              accessToken: response.accessToken,
              refreshToken: response.refreshToken,
              accessTokenExpiresAt: response.accessTokenExpiresAt,
              refreshTokenExpiresAt: response.refreshTokenExpiresAt,
            ),
          );
        } catch (_) {
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
      await _localStore.clearTokens();
    } catch (_) {}
    try {
      await _localStore.clearUser();
    } catch (_) {}
    _sessionManager.clear();
  }
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
