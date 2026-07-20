import 'package:auth/src/data/lifecycle/auth_lifecycle_diagnostic.dart';

abstract interface class AuthLifecycleDiagnosticSink {
  void reportAll(Iterable<AuthLifecycleDiagnostic> diagnostics);
}
