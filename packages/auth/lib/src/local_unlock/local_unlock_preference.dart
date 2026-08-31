import 'dart:convert';

enum LocalUnlockPreference { disabled, enabled }

final class LocalUnlockPreferenceCodec {
  const LocalUnlockPreferenceCodec();

  static const version = 1;

  String encode(LocalUnlockPreference preference) =>
      jsonEncode(<String, Object>{
        'version': version,
        'enabled': preference == LocalUnlockPreference.enabled,
      });

  LocalUnlockPreference decode(String raw) {
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic> || decoded['version'] != version) {
      throw const FormatException('Invalid local unlock preference payload.');
    }
    final enabled = decoded['enabled'];
    if (enabled is! bool) {
      throw const FormatException('Invalid local unlock enabled value.');
    }
    return enabled
        ? LocalUnlockPreference.enabled
        : LocalUnlockPreference.disabled;
  }
}

sealed class LocalUnlockPreferenceReadResult {
  const LocalUnlockPreferenceReadResult();

  const factory LocalUnlockPreferenceReadResult.absent() =
      LocalUnlockPreferenceReadAbsent;
  const factory LocalUnlockPreferenceReadResult.present(
    LocalUnlockPreference preference,
  ) = LocalUnlockPreferenceReadPresent;
  const factory LocalUnlockPreferenceReadResult.corrupted() =
      LocalUnlockPreferenceReadCorrupted;
}

final class LocalUnlockPreferenceReadAbsent
    extends LocalUnlockPreferenceReadResult {
  const LocalUnlockPreferenceReadAbsent();
}

final class LocalUnlockPreferenceReadPresent
    extends LocalUnlockPreferenceReadResult {
  const LocalUnlockPreferenceReadPresent(this.preference);

  final LocalUnlockPreference preference;
}

final class LocalUnlockPreferenceReadCorrupted
    extends LocalUnlockPreferenceReadResult {
  const LocalUnlockPreferenceReadCorrupted();
}

/// Local unlock preference 的 durable boundary；讀取時保留 absent / corrupted distinction。
abstract interface class LocalUnlockPreferenceStore {
  Future<LocalUnlockPreferenceReadResult> read();
  Future<void> write(LocalUnlockPreference preference);
  Future<void> clear();
}
