import 'dart:async';

typedef ErrorReportCleanupScheduler = void Function(void Function() cleanup);

/// 同一event-loop turn內，以error identity協調多個global reporting entrypoint。
///
/// Bloc與bootstrap error都可能在上報後rethrow至Platform hook；這裡只標記
/// 原始error與stack object identity，不比較字串、runtime type或stack內容。
final class ErrorReportDeduplicator {
  ErrorReportDeduplicator({ErrorReportCleanupScheduler? scheduleCleanup})
    : _scheduleCleanup = scheduleCleanup ?? Timer.run;

  final ErrorReportCleanupScheduler _scheduleCleanup;
  final List<_ReportedErrorEntry> _reportedErrors = <_ReportedErrorEntry>[];

  void markReported(Object error, StackTrace stackTrace) {
    final generation = Object();
    _reportedErrors.removeWhere(
      (entry) =>
          identical(entry.error, error) &&
          identical(entry.stackTrace, stackTrace),
    );
    _reportedErrors.add(
      _ReportedErrorEntry(
        error: error,
        stackTrace: stackTrace,
        generation: generation,
      ),
    );
    _scheduleCleanup(() {
      _reportedErrors.removeWhere(
        (entry) =>
            identical(entry.error, error) &&
            identical(entry.stackTrace, stackTrace) &&
            identical(entry.generation, generation),
      );
    });
  }

  bool consumeReported(Object error, StackTrace stackTrace) {
    final index = _reportedErrors.indexWhere(
      (entry) =>
          identical(entry.error, error) &&
          identical(entry.stackTrace, stackTrace),
    );
    if (index < 0) return false;
    _reportedErrors.removeAt(index);
    return true;
  }
}

final class _ReportedErrorEntry {
  const _ReportedErrorEntry({
    required this.error,
    required this.stackTrace,
    required this.generation,
  });

  final Object error;
  final StackTrace stackTrace;
  final Object generation;
}
