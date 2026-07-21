import 'package:auth/src/domain/entities/auth_authenticated_result.dart';
import 'package:auth/src/domain/entities/otp_challenge.dart';

/// Password login can either authenticate immediately or require OTP.
sealed class AuthLoginResult {
  const AuthLoginResult();

  const factory AuthLoginResult.authenticated(AuthAuthenticatedResult result) =
      AuthLoginAuthenticated;

  const factory AuthLoginResult.otpChallenge(OtpChallenge challenge) =
      AuthLoginOtpChallenge;

  T when<T>({
    required T Function(AuthAuthenticatedResult result) authenticated,
    required T Function(OtpChallenge challenge) otpChallenge,
  }) {
    return switch (this) {
      AuthLoginAuthenticated(:final result) => authenticated(result),
      AuthLoginOtpChallenge(:final challenge) => otpChallenge(challenge),
    };
  }

  @override
  String toString() => 'AuthLoginResult(${runtimeType.toString()})';
}

final class AuthLoginAuthenticated extends AuthLoginResult {
  const AuthLoginAuthenticated(this.result);

  final AuthAuthenticatedResult result;
}

final class AuthLoginOtpChallenge extends AuthLoginResult {
  const AuthLoginOtpChallenge(this.challenge);

  final OtpChallenge challenge;
}

/// Compatibility name for the authenticated payload used before Milestone 20.
typedef AuthResult = AuthAuthenticatedResult;
