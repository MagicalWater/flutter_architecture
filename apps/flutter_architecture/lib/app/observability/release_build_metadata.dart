/// Build 額外提供的 release metadata，目前只保存可選的 Git commit SHA。
///
/// 本機開發沒有 SHA 也可以正常執行；CI／release build 有提供時才帶進 observability。
final class ReleaseBuildMetadata {
  const ReleaseBuildMetadata._(this.commitSha);

  const ReleaseBuildMetadata.absent() : this._(null);

  factory ReleaseBuildMetadata.fromValue(String value) {
    final normalized = value.trim();
    return normalized.isEmpty
        ? const ReleaseBuildMetadata.absent()
        : ReleaseBuildMetadata._(normalized);
  }

  factory ReleaseBuildMetadata.fromEnvironment() {
    const commitSha = String.fromEnvironment(
      'APP_COMMIT_SHA',
      defaultValue: '',
    );
    return ReleaseBuildMetadata.fromValue(commitSha);
  }

  final String? commitSha;

  @override
  String toString() {
    return 'ReleaseBuildMetadata(hasCommitSha: ${commitSha != null})';
  }
}
