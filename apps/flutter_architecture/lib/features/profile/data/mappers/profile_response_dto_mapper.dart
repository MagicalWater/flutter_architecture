import 'package:api_client/api_client.dart';
import 'package:flutter_architecture/features/profile/domain/entities/profile.dart';

/// 將 Profile API DTO 轉為 Profile Domain Entity。
extension ProfileResponseDtoMapper on ProfileResponseDto {
  Profile toDomain() => Profile(id: id, name: name);
}
