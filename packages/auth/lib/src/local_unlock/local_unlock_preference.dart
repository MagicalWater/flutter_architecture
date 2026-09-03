/// 保存使用者是否開啟「下次啟動要先做 Face ID／指紋解鎖」。
///
/// `false` 同時代表未設定與明確停用；如果 storage 讀壞了或根本無法判斷，必須回報
/// failure，不能偷偷當成 `false`，否則 App 可能在不確定設定時直接跳過本機解鎖。
abstract interface class LocalUnlockPreferenceStore {
  Future<bool> readEnabled();
  Future<void> writeEnabled(bool enabled);
  Future<void> clear();
}
