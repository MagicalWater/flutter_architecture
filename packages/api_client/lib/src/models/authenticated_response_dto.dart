import 'package:freezed_annotation/freezed_annotation.dart';

part 'authenticated_response_dto.freezed.dart';
part 'authenticated_response_dto.g.dart';

/// 帶有 credential 的 authenticated response payload。
@Freezed(toStringOverride: false)
abstract class AuthenticatedResponseDto with _$AuthenticatedResponseDto {
  const factory AuthenticatedResponseDto({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String userName,
  }) = _AuthenticatedResponseDto;

  factory AuthenticatedResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthenticatedResponseDtoFromJson(json);
}
