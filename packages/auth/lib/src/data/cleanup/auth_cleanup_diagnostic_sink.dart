import 'package:auth/src/data/cleanup/auth_cleanup_diagnostic.dart';

abstract interface class AuthCleanupDiagnosticSink {
  void reportAll(Iterable<AuthCleanupDiagnostic> diagnostics);
}
