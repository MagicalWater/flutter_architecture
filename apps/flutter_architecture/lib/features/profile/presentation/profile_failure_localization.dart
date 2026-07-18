import 'package:core/core.dart';
import 'package:flutter_architecture/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';

String localizedProfileFailure(
  AppLocalizations l10n, {
  required Failure failure,
  required ProfileFailureOperation operation,
}) {
  if (operation == ProfileFailureOperation.load && failure.code == '401') {
    return l10n.profileSessionExpiredMessage;
  }

  return switch (operation) {
    ProfileFailureOperation.load => l10n.profileLoadFailureMessage,
    ProfileFailureOperation.logout => l10n.profileLogoutFailureMessage,
  };
}
