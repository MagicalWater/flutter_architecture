import 'package:core/core.dart';
import 'package:flutter_architecture/features/profile/data/mappers/profile_response_dto_mapper.dart';
import 'package:flutter_architecture/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:flutter_architecture/features/profile/domain/entities/profile.dart';
import 'package:flutter_architecture/features/profile/domain/repositories/profile_repository.dart';
import 'package:injectable/injectable.dart';

/// ProfileRepository 的 Data Layer 實作。
///
/// 透過 ProfileRemoteDataSource 取得遠端 DTO，再映射為 Domain Entity。
@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Result<Profile>> getProfile() async {
    try {
      final response = await _remoteDataSource.getProfile();
      return Success(response.toDomain());
    } on AppException catch (error) {
      return FailureResult(
        mapAppExceptionToFailure(
          error,
          fallbackMessage: 'Profile retrieval failed.',
        ),
      );
    }
  }
}
