import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

/// Login API 回傳資料。
///
/// ## 為什麼這是 Response，不是 Entity？
///
/// Response 屬於 API 格式，會隨後端變動。
///
/// Entity 屬於 Domain Layer，代表 App 業務真正需要的資料。
@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String accessToken,
    required String userId,
    required String userName,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}
