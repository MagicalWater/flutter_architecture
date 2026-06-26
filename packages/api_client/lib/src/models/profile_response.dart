import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_response.freezed.dart';
part 'profile_response.g.dart';

/// Profile API 回傳資料。
///
/// API response 不會直接暴露到 Presentation Layer。
///
/// Data Layer 會負責把它轉成 Domain Entity。
@freezed
class ProfileResponse with _$ProfileResponse {
  const factory ProfileResponse({
    required String id,
    required String name,
  }) = _ProfileResponse;

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);
}
