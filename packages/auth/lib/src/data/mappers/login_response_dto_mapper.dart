import 'package:api_client/api_client.dart';
import 'package:auth/src/data/mappers/otp_challenge_dto_mapper.dart';
import 'package:auth/src/domain/entities/auth_authenticated_result.dart';
import 'package:auth/src/domain/entities/auth_result.dart';
import 'package:auth/src/domain/entities/auth_user.dart';

extension AuthenticatedResponseDtoMapper on AuthenticatedResponseDto {
  AuthAuthenticatedResult toDomain() {
    if (accessToken.trim().isEmpty ||
        refreshToken.trim().isEmpty ||
        userId.trim().isEmpty ||
        userName.trim().isEmpty) {
      throw const FormatException('Invalid authenticated response');
    }
    return AuthAuthenticatedResult(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: AuthUser(id: userId, name: userName),
    );
  }
}

extension LoginResponseDtoMapper on LoginResponseDto {
  AuthLoginResult toDomain() => when(
    authenticated: (value) => AuthLoginResult.authenticated(value.toDomain()),
    otpChallenge: (challenge) =>
        AuthLoginResult.otpChallenge(challenge.toDomain()),
  );
}
