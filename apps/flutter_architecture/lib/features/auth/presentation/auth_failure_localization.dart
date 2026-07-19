import 'package:core/core.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';

String localizedAuthFailure(
  AppLocalizations l10n, {
  required Failure failure,
  required AuthFailureOperation operation,
}) {
  if (operation == AuthFailureOperation.login && failure.httpStatus == 401) {
    return l10n.authInvalidCredentialsMessage;
  }

  return switch (operation) {
    AuthFailureOperation.restore => l10n.authRestoreFailureMessage,
    AuthFailureOperation.login => l10n.authLoginFailureMessage,
    AuthFailureOperation.logout => l10n.authLogoutFailureMessage,
  };
}
