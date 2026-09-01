import 'dart:collection';

import 'package:auth/src/data/cleanup/auth_cleanup_diagnostic.dart';
import 'package:auth/src/data/stores/auth_credential_store.dart';
import 'package:auth/src/data/stores/auth_legacy_credential_store.dart';
import 'package:auth/src/data/stores/auth_user_store.dart';
import 'package:auth/src/local_unlock/local_unlock_preference.dart';
import 'package:core/core.dart';

/// 統一執行 Auth state 的 destructive cleanup，避免單一 store 失敗中斷其餘清理。
final class AuthStateCleanup {
  const AuthStateCleanup({
    required AuthCredentialStore secureCredentialStore,
    required AuthLegacyCredentialStore legacyCredentialStore,
    required AuthUserStore userStore,
    LocalUnlockPreferenceStore? localUnlockPreferenceStore,
  }) : _secureCredentialStore = secureCredentialStore,
       _legacyCredentialStore = legacyCredentialStore,
       _userStore = userStore,
       _localUnlockPreferenceStore = localUnlockPreferenceStore;

  final AuthCredentialStore _secureCredentialStore;
  final AuthLegacyCredentialStore _legacyCredentialStore;
  final AuthUserStore _userStore;
  final LocalUnlockPreferenceStore? _localUnlockPreferenceStore;

  Future<AuthStateCleanupResult> clearAllUnlocked() async {
    final diagnostics = <AuthCleanupDiagnostic>[];

    // Cleanup 採 best-effort fan-out：單一 store 失敗不能阻止其他 credential /
    // user state 被移除。所有 attempt 結束後再由 result 決定 failure priority。
    Future<void> attempt(
      AuthCleanupOperation operation,
      Future<void> Function() action,
    ) async {
      try {
        await action();
      } catch (error, stackTrace) {
        diagnostics.add(
          AuthCleanupDiagnostic(
            operation: operation,
            error: error,
            stackTrace: stackTrace,
          ),
        );
      }
    }

    await attempt(
      AuthCleanupOperation.secureCleanup,
      _secureCredentialStore.clearCredential,
    );
    await attempt(
      AuthCleanupOperation.legacyCleanup,
      _legacyCredentialStore.clearLegacyCredential,
    );
    await attempt(AuthCleanupOperation.userCleanup, _userStore.clearUser);
    final localUnlockPreferenceStore = _localUnlockPreferenceStore;
    if (localUnlockPreferenceStore != null) {
      await attempt(
        AuthCleanupOperation.localUnlockPreferenceCleanup,
        localUnlockPreferenceStore.clear,
      );
    }

    return AuthStateCleanupResult(diagnostics);
  }
}

/// 保存 cleanup 的完整診斷，並集中決定 expected / unexpected failure priority。
final class AuthStateCleanupResult {
  AuthStateCleanupResult(Iterable<AuthCleanupDiagnostic> diagnostics)
    : diagnostics = UnmodifiableListView<AuthCleanupDiagnostic>(
        List<AuthCleanupDiagnostic>.of(diagnostics),
      );

  final List<AuthCleanupDiagnostic> diagnostics;

  bool get isSuccess => diagnostics.isEmpty;

  bool get hasUnexpectedFailure =>
      diagnostics.any((diagnostic) => !_isExpected(diagnostic.error));

  void throwIfUnexpected() {
    final diagnostic = _primary(unexpectedOnly: true);
    if (diagnostic != null) {
      Error.throwWithStackTrace(diagnostic.error, diagnostic.stackTrace);
    }
  }

  void throwIfFailed() {
    final diagnostic = _primary();
    if (diagnostic != null) {
      Error.throwWithStackTrace(diagnostic.error, diagnostic.stackTrace);
    }
  }

  AuthCleanupDiagnostic? _primary({bool unexpectedOnly = false}) {
    // Unknown / unexpected failure 優先於已知 local-storage failure，避免 cleanup
    // 把真正的 programming / platform defect 降級成可預期 operational error。
    for (final diagnostic in diagnostics) {
      if (!_isExpected(diagnostic.error)) return diagnostic;
    }
    if (unexpectedOnly || diagnostics.isEmpty) return null;
    return diagnostics.first;
  }

  static bool _isExpected(Object error) {
    return error is AppException && error.kind == AppExceptionKind.localStorage;
  }
}
