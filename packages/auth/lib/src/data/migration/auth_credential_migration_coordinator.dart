import 'package:auth/src/data/migration/auth_credential_migration_result.dart';
import 'package:auth/src/data/stores/auth_credential_store.dart';
import 'package:auth/src/data/stores/auth_legacy_credential_store.dart';
import 'package:auth/src/data/stores/auth_user_store.dart';

/// Secure、Legacy與User store之間唯一的credential migration policy owner。
///
/// 呼叫方必須先取得Auth lifecycle的exclusive ownership；Coordinator本身只根據
/// 三個Auth-specific stores的真實狀態進行resolution，不持有runtime Session狀態。
final class AuthCredentialMigrationCoordinator {
  const AuthCredentialMigrationCoordinator(
    this._secureCredentialStore,
    this._legacyCredentialStore,
    this._userStore,
  );

  final AuthCredentialStore _secureCredentialStore;
  final AuthLegacyCredentialStore _legacyCredentialStore;
  final AuthUserStore _userStore;

  /// 在呼叫方已持有exclusive ownership時解析credential authority。
  Future<AuthCredentialMigrationResult> resolveUnlocked() {
    // Store fields會由後續decision-matrix tasks逐步使用。
    final _ = (_secureCredentialStore, _legacyCredentialStore, _userStore);
    throw UnimplementedError('Credential migration matrix is not implemented.');
  }
}
