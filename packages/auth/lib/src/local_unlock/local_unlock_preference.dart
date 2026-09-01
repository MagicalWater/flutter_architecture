/// Local unlock preference 的 durable boundary。
///
/// `false` 同時代表未設定與明確停用；無法可靠判讀的 durable state 必須以 failure
/// 回報，不能降級成 disabled，避免 startup / resume 在未知狀態下 fail open。
abstract interface class LocalUnlockPreferenceStore {
  Future<bool> readEnabled();
  Future<void> writeEnabled(bool enabled);
  Future<void> clear();
}
