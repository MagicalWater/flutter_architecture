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

/// Access token 過期時，安全刷新目前登入 Session 的 Token Pair。
///
/// 同一個 Session 遇到多個 401 時只會真的打一次 refresh API；其他 request 共用結果。
/// Refresh 期間如果使用者已登出、重新登入或換了 Session，舊 refresh 結果就直接丟棄，
/// 不能拿來覆蓋新的 credential 或 runtime Session。
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
      // 原本發出 401 的 Session 已經不存在，代表這個 refresh 已經過期。
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
        // 只有同一次登入、同一顆失效 token 才能共用同一個 refresh。
        return existing.future;
      }
      // 不同 Session 不能共用既有 refresh。先等舊 refresh 結束，再重新看最新 Session，
      // 避免同時狂打 refresh API，也避免把 A Session 的結果拿去給 B Session。
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

  /// 完成這一批共用 refresh，並通知所有正在等待同一結果的 request。
  ///
  /// 結束時只清掉「自己建立的」in-flight slot；如果期間已經有新的 refresh 開始，
  /// 舊 completion 不能把新 refresh 的 slot 清掉。
  Future<void> _completeRefresh({
    required _InFlightRefresh inFlight,
    required Completer<AuthRefreshResult> completer,
  }) async {
    try {
      completer.complete(await _performRefresh(inFlight));
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
    } finally {
      // 只清自己的 slot，避免舊 refresh 晚回來時誤刪新的 in-flight refresh。
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

  /// 執行完整 refresh：先確認 storage 與 runtime Session 對得上，再呼叫後端刷新 token。
  ///
  /// 網路 request 不持有 mutation lock；response 回來後重新確認 Session 還是原本那一個，
  /// 先把新 Token Pair 寫進 secure storage，成功後才更新記憶體中的 access token。
  Future<AuthRefreshResult> _performRefresh(_InFlightRefresh inFlight) async {
    late final StoredAuthTokens tokens;
    try {
      final stored = await _mutationCoordinator.runExclusive(() async {
        // 讀 credential 的同時確認 runtime Session 還是同一次登入；如果已換 Session，
        // 就不要再拿舊 refresh token 往下走。
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
      // HTTP refresh 不持有 mutation lock，避免慢網路把 login／logout 卡住；
      // response 回來後再重新鎖住並確認 Session 沒變。
      final response = await _remoteDataSource.refresh(tokens.refreshToken);
      final outcome = await _mutationCoordinator.runExclusive(() async {
        if (!_isSameSession(inFlight.generation, inFlight.userId)) {
          return const _SecureRefreshOutcome(
            result: AuthRefreshResult.sessionChanged,
          );
        }
        try {
          // 先把完整 Token Pair 寫進 secure storage；只有寫成功才更新 runtime token，
          // 避免 App 記憶體已是新 token，但重啟後 storage 還是舊 token。
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
          // Storage 已寫失敗時不能只留著記憶體中的已登入 Session；否則 App 重啟後
          // 根本無法還原同一份登入狀態，所以要做 cleanup 並清掉 runtime Session。
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

  /// Refresh token 已失效時，只清除「當初發出這次 refresh 的 Session」。
  ///
  /// 如果使用者在等待期間已重新登入，就只回報 Session changed，不能讓舊 refresh
  /// 把剛建立的新登入狀態一起清掉。
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

  /// Caller 已經持有 Auth mutation lock 時執行 cleanup；這裡不再自己加鎖，
  /// 避免同一把 lock 等自己造成卡死。
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
