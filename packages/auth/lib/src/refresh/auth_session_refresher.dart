import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:auth/src/data/data_sources/auth_refresh_remote_data_source.dart';
import 'package:auth/src/data/exceptions/invalid_refresh_credential_exception.dart';
import 'package:auth/src/data/exceptions/temporary_refresh_exception.dart';
import 'package:auth/src/data/cleanup/auth_cleanup_diagnostic.dart';
import 'package:auth/src/data/cleanup/auth_cleanup_diagnostic_sink.dart';
import 'package:auth/src/data/cleanup/auth_state_cleanup.dart';
import 'package:auth/src/data/models/stored_auth_tokens.dart';
import 'package:auth/src/data/stores/auth_credential_read_result.dart';
import 'package:auth/src/data/stores/auth_credential_store.dart';
import 'package:auth/src/data/stores/auth_legacy_credential_store.dart';
import 'package:auth/src/data/stores/auth_user_store.dart';
import 'package:auth/src/session/session_manager.dart';
import 'package:auth/src/session/auth_state_mutation_coordinator.dart';
import 'package:core/core.dart';

/// 協調目前 authenticated Session 的 refresh，並隔離不同 lifecycle identity。
///
/// 同一 Session + failed token 只共享一個 in-flight refresh；任何 refresh 結果
/// 在寫回 credential / runtime Session 前都必須重新確認仍屬於原本 lifecycle。
class AuthSessionRefresher implements AuthRefresher {
  AuthSessionRefresher(
    this._remoteDataSource,
    this._credentialStore,
    this._legacyCredentialStore,
    this._userStore,
    this._sessionManager,
    this._mutationCoordinator,
    this._diagnosticSink,
  );

  final AuthRefreshRemoteDataSource _remoteDataSource;
  final AuthCredentialStore _credentialStore;
  final AuthLegacyCredentialStore _legacyCredentialStore;
  final AuthUserStore _userStore;
  final SessionManager _sessionManager;
  final AuthStateMutationCoordinator _mutationCoordinator;
  final AuthCleanupDiagnosticSink _diagnosticSink;

  _InFlightRefresh? _inFlight;

  @override
  Future<AuthRefreshResult> refresh({required String failedAccessToken}) async {
    final session = _sessionManager.currentSession;
    if (session == null) {
      // 呼叫方原本要 refresh 的 Session 已不存在；這是 ownership 已改變的
      // race-resolution result，不限定於「切換帳號」。
      return AuthRefreshResult.sessionChanged;
    }
    if (session.accessToken != failedAccessToken) {
      // 同一 Session 已持有不同 token，代表 refresh requirement 已被其他
      // operation 滿足；Success 不保證本次 invocation 自己打過 refresh API。
      return AuthRefreshResult.success;
    }

    final existing = _inFlight;
    if (existing != null) {
      if (existing.matches(
        generation: session.generation,
        userId: session.userId,
        failedAccessToken: failedAccessToken,
      )) {
        // 只有完全相同的 lifecycle identity + failed token 才可共享 single-flight。
        return existing.future;
      }
      // 不同 identity 不可併入既有 refresh；先等目前 operation 收斂，再以
      // 最新 Session 狀態重新 admission，避免 refresh storm 與跨 Session 共用。
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

  /// 將單次 refresh operation 的結果回填給所有等待者，並只在自己仍是 owner 時
  /// 清除 in-flight slot，避免舊 completion 蓋掉新的 refresh。
  Future<void> _completeRefresh({
    required _InFlightRefresh inFlight,
    required Completer<AuthRefreshResult> completer,
  }) async {
    try {
      completer.complete(await _performRefresh(inFlight));
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
    } finally {
      // 舊 operation completion 不得清掉後來建立的新 in-flight owner。
      if (identical(_inFlight, inFlight)) {
        _inFlight = null;
      }
    }
  }

  bool _isSameSession(int generation, String userId) {
    final current = _sessionManager.currentSession;
    return current != null &&
        current.generation == generation &&
        current.userId == userId;
  }

  /// 執行完整 refresh flow：先驗證 durable/runtime identity，再離鎖呼叫 remote，
  /// 最後重新取得 mutation ownership 後 persistence-first commit rotated tokens。
  Future<AuthRefreshResult> _performRefresh(_InFlightRefresh inFlight) async {
    late final StoredAuthTokens tokens;
    try {
      final stored = await _mutationCoordinator.runExclusive(() async {
        // Credential snapshot 與 runtime Session 必須在同一 mutation serialization
        // boundary 內確認；失去 lifecycle ownership 就停止讀取 refresh credential。
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
        return AuthRefreshResult.sessionChanged;
      }
      if (stored == null) {
        return _invalidateSecureSession(
          generation: inFlight.generation,
          userId: inFlight.userId,
          expiredResult: AuthRefreshResult.sessionExpired,
        );
      }
      tokens = stored;
    } on AppException catch (error, stackTrace) {
      if (error.kind != AppExceptionKind.localStorage) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      return _isSameSession(inFlight.generation, inFlight.userId)
          ? AuthRefreshResult.localStateFailure
          : AuthRefreshResult.sessionChanged;
    }

    try {
      // HTTP refresh 本身刻意不持有 mutation lock；否則慢網路會阻塞 login / logout。
      // Response 回來後再取得 exclusive ownership 並重新驗證 Session identity。
      final response = await _remoteDataSource.refresh(tokens.refreshToken);
      final outcome = await _mutationCoordinator.runExclusive(() async {
        if (!_isSameSession(inFlight.generation, inFlight.userId)) {
          return const _SecureRefreshOutcome(
            result: AuthRefreshResult.sessionChanged,
          );
        }
        try {
          // Persistence-first：只有完整 credential snapshot 寫入成功後才更新
          // runtime token，避免 memory state 與 durable authority 分裂。
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
          // Credential commit 已失敗時執行補償式 cleanup，並清除 runtime Session；
          // 不允許保留一個無法由 durable state 恢復的 authenticated Session。
          final cleanup = await _clearSecureAuthStateUnlocked();
          _sessionManager.clear();
          return _SecureRefreshOutcome(
            result: AuthRefreshResult.localStateFailure,
            cleanup: cleanup,
          );
        }
        _sessionManager.updateAccessToken(response.accessToken);
        return const _SecureRefreshOutcome(result: AuthRefreshResult.success);
      });
      return _completeOutcome(outcome);
    } on InvalidRefreshCredentialException {
      return _invalidateSecureSession(
        generation: inFlight.generation,
        userId: inFlight.userId,
        expiredResult: AuthRefreshResult.sessionExpired,
      );
    } on TemporaryRefreshException {
      return AuthRefreshResult.temporarilyUnavailable;
    }
  }

  /// 只有原 Session identity 仍有效時才清除 auth state；若 Session 已切換，
  /// 直接回報 changed，避免舊 refresh invalidation 清掉新登入狀態。
  Future<AuthRefreshResult> _invalidateSecureSession({
    required int generation,
    required String userId,
    required AuthRefreshResult expiredResult,
  }) async {
    final outcome = await _mutationCoordinator.runExclusive(() async {
      if (!_isSameSession(generation, userId)) {
        return const _SecureRefreshOutcome(
          result: AuthRefreshResult.sessionChanged,
        );
      }
      final cleanup = await _clearSecureAuthStateUnlocked();
      _sessionManager.clear();
      return _SecureRefreshOutcome(result: expiredResult, cleanup: cleanup);
    });
    return _completeOutcome(outcome);
  }

  /// 在外層已持有 mutation serialization 時執行 auth durable-state cleanup。
  /// 此 helper 不自行加鎖，避免同一 coordinator 上形成巢狀等待。
  Future<AuthStateCleanupResult> _clearSecureAuthStateUnlocked() {
    return AuthStateCleanup(
      secureCredentialStore: _credentialStore,
      legacyCredentialStore: _legacyCredentialStore,
      userStore: _userStore,
    ).clearAllUnlocked();
  }

  /// 完成 cleanup-aware refresh 結果：預期 storage diagnostics 只做 best-effort
  /// reporting；unexpected cleanup failure 仍必須中斷正常 refresh result。
  AuthRefreshResult _completeOutcome(_SecureRefreshOutcome outcome) {
    final cleanup = outcome.cleanup;
    if (cleanup == null) return outcome.result;
    _reportExpectedBestEffort(cleanup.diagnostics);
    cleanup.throwIfUnexpected();
    return outcome.result;
  }

  /// 只上報可預期的 local-storage cleanup failure；reporter 自身失敗不得改變
  /// session expiration / refresh outcome。
  void _reportExpectedBestEffort(Iterable<AuthCleanupDiagnostic> diagnostics) {
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
  final AuthStateCleanupResult? cleanup;
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
