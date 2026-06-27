import 'package:auth/src/domain/entities/auth_user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user_model.freezed.dart';
part 'auth_user_model.g.dart';

/// Data Layer 的使用者 Model。
///
/// ## 為什麼需要 Model？
///
/// Model 對應外部資料格式，例如 API JSON 或 SQLite row。
///
/// Entity 則是 Domain Layer 真正需要的資料。
@freezed
class AuthUserModel with _$AuthUserModel {
  const factory AuthUserModel({
    required String id,
    required String name,
  }) = _AuthUserModel;

  const AuthUserModel._();

  factory AuthUserModel.fromJson(Map<String, dynamic> json) =>
      _$AuthUserModelFromJson(json);

  factory AuthUserModel.fromEntity(AuthUser user) {
    return AuthUserModel(
      id: user.id,
      name: user.name,
    );
  }

  AuthUser toEntity() {
    return AuthUser(
      id: id,
      name: name,
    );
  }
}
