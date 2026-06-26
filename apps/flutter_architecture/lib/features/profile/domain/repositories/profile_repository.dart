import 'package:core/core.dart';
import 'package:flutter_architecture/features/profile/domain/entities/profile.dart';

/// Profile Repository 抽象。
///
/// Domain Layer 只知道「可以取得 Profile」。
///
/// 至於資料來自 API、SQLite 或 cache，交給 Data Layer 決定。
abstract interface class ProfileRepository {
  Future<Result<Profile>> getProfile();
}
