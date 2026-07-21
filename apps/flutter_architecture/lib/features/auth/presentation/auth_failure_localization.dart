import 'package:auth/auth.dart';
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

  final otpDetails = failure.cause is OtpFailureDetails
      ? failure.cause as OtpFailureDetails
      : null;
  if (otpDetails != null) {
    return switch (otpDetails.kind) {
      OtpFailureKind.invalidCode =>
        otpDetails.attemptsRemaining == null
            ? l10n.otpInvalidCodeMessage
            : l10n.otpInvalidCodeAttemptsMessage(otpDetails.attemptsRemaining!),
      OtpFailureKind.challengeExpired => l10n.otpExpiredMessage,
      OtpFailureKind.tooManyAttempts => l10n.otpTooManyAttemptsMessage,
      OtpFailureKind.resendCooldown => l10n.otpResendCooldownMessage,
      OtpFailureKind.challengeInvalidated => l10n.otpInvalidatedMessage,
      OtpFailureKind.protocolViolation => l10n.otpGenericFailureMessage,
    };
  }

  return switch (operation) {
    AuthFailureOperation.restore => l10n.authRestoreFailureMessage,
    AuthFailureOperation.login => l10n.authLoginFailureMessage,
    AuthFailureOperation.verifyOtp => l10n.otpGenericFailureMessage,
    AuthFailureOperation.resendOtp => l10n.otpGenericFailureMessage,
    AuthFailureOperation.logout => l10n.authLogoutFailureMessage,
  };
}
