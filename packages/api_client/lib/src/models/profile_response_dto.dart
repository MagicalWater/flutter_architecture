import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_response_dto.freezed.dart';
part 'profile_response_dto.g.dart';

/// Profile API response DTO。
@freezed
abstract class ProfileResponseDto with _$ProfileResponseDto {
  const factory ProfileResponseDto({
    required String id,
    required String name,
  }) = _ProfileResponseDto;

  factory ProfileResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseDtoFromJson(json);
}
