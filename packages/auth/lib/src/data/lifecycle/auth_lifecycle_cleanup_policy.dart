import 'dart:collection';

import 'package:auth/src/data/lifecycle/auth_lifecycle_diagnostic.dart';
import 'package:auth/src/data/stores/auth_credential_store.dart';
import 'package:auth/src/data/stores/auth_legacy_credential_store.dart';
import 'package:auth/src/data/stores/auth_user_store.dart';
import 'package:auth/src/local_unlock/local_unlock_preference.dart';
import 'package:core/core.dart';

final class AuthLifecycleCleanupPolicy {
  const AuthLifecycleCleanupPolicy({
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

  Future<AuthLifecycleCleanupResult> clearAllUnlocked() async {
    final diagnostics = <AuthLifecycleDiagnostic>[];

    Future<void> attempt(
      AuthLifecycleDiagnosticOperation operation,
      Future<void> Function() action,
    ) async {
      try {
        await action();
      } catch (error, stackTrace) {
        diagnostics.add(
          AuthLifecycleDiagnostic(
            operation: operation,
            error: error,
            stackTrace: stackTrace,
          ),
        );
      }
    }

    await attempt(
      AuthLifecycleDiagnosticOperation.secureCleanup,
      _secureCredentialStore.clearCredential,
    );
    await attempt(
      AuthLifecycleDiagnosticOperation.legacyCleanup,
      _legacyCredentialStore.clearLegacyCredential,
    );
    await attempt(
      AuthLifecycleDiagnosticOperation.userCleanup,
      _userStore.clearUser,
    );
    final localUnlockPreferenceStore = _localUnlockPreferenceStore;
    if (localUnlockPreferenceStore != null) {
      await attempt(
        AuthLifecycleDiagnosticOperation.localUnlockPreferenceCleanup,
        localUnlockPreferenceStore.clear,
      );
    }

    return AuthLifecycleCleanupResult(diagnostics);
  }
}

final class AuthLifecycleCleanupResult {
  AuthLifecycleCleanupResult(Iterable<AuthLifecycleDiagnostic> diagnostics)
    : diagnostics = UnmodifiableListView<AuthLifecycleDiagnostic>(
        List<AuthLifecycleDiagnostic>.of(diagnostics),
      );

  final List<AuthLifecycleDiagnostic> diagnostics;

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

  AuthLifecycleDiagnostic? _primary({bool unexpectedOnly = false}) {
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
