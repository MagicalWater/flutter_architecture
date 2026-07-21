// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authenticated_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthenticatedResponseDto _$AuthenticatedResponseDtoFromJson(
  Map<String, dynamic> json,
) => _AuthenticatedResponseDto(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
);

Map<String, dynamic> _$AuthenticatedResponseDtoToJson(
  _AuthenticatedResponseDto instance,
) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'userId': instance.userId,
  'userName': instance.userName,
};
