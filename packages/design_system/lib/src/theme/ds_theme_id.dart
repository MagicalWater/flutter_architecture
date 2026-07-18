/// 可持久化且不依賴 class name / enum name 的穩定 Theme ID。
final class DsThemeId {
  factory DsThemeId(String value) {
    if (!_validPattern.hasMatch(value)) {
      throw ArgumentError.value(
        value,
        'value',
        'Theme ID 必須以小寫英文字母開頭，且只能包含小寫英文字母、數字、底線或連字號',
      );
    }
    return DsThemeId._(value);
  }

  const DsThemeId._(this.value);

  static final RegExp _validPattern = RegExp(r'^[a-z][a-z0-9_-]*$');

  final String value;

  @override
  bool operator ==(Object other) => other is DsThemeId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'DsThemeId($value)';
}
