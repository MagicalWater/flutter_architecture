import 'package:auth/src/domain/entities/otp_challenge.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:core/core.dart';

final class ResendOtpUseCase {
  const ResendOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<OtpChallenge>> execute({required String challengeId}) =>
      _repository.resendOtp(challengeId: challengeId);
}
