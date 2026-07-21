import 'package:auth/src/domain/entities/auth_authenticated_result.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:core/core.dart';

final class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthAuthenticatedResult>> execute({
    required String challengeId,
    required String code,
  }) => _repository.verifyOtp(challengeId: challengeId, code: code);
}
