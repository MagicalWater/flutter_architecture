import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:flutter_architecture/features/profile/domain/entities/profile.dart';
import 'package:flutter_architecture/features/profile/domain/repositories/profile_repository.dart';
import 'package:injectable/injectable.dart';

/// ProfileRepository 的 Data Layer 實作。
///
/// 第一階段直接透過 ProfileApiClient 取得 mock profile。
@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._profileApiClient);

  final ProfileApiClient _profileApiClient;

  @override
  Future<Result<Profile>> getProfile() async {
    try {
      final response = await _profileApiClient.getProfile();

      return Success(
        Profile(
          id: response.id,
          name: response.name,
        ),
      );
    } catch (error) {
      return FailureResult(
        Failure(
          message: '取得 Profile 失敗',
          cause: error,
        ),
      );
    }
  }
}
