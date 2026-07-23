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
