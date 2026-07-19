import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_architecture/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:flutter_architecture/features/profile/data/mappers/profile_response_dto_mapper.dart';
import 'package:flutter_architecture/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ProfileResponseDto mapper 會轉為 Profile entity', () {
    const dto = ProfileResponseDto(
      id: 'user-001',
      name: 'Water Magical',
    );

    final profile = dto.toDomain();

    expect(profile.id, 'user-001');
    expect(profile.name, 'Water Magical');
  });

  test('ProfileRemoteDataSource 會把 DioException 映射為 AppException', () async {
    final dataSource = ProfileRemoteDataSource(
      _ThrowingProfileApi(_dioException()),
    );

    await expectLater(
      dataSource.getProfile(),
      throwsA(
        isA<AppException>().having(
          (error) => error.code,
          'code',
          '401',
        ),
      ),
    );
  });

  test('ProfileRepository 會把 AppException 轉為 domain Failure', () async {
    final repository = ProfileRepositoryImpl(
      ProfileRemoteDataSource(
        _ThrowingProfileApi(
          const AppException(
            message: 'API request failed',
            code: '401',
          ),
        ),
      ),
    );

    final result = await repository.getProfile();

    final message = result.when(
      success: (_) => 'unexpected success',
      failure: (failure) => failure.message,
    );

    expect(message, 'Profile retrieval failed.');
  });

  test('ProfileRepository 不會把未知錯誤轉為 Failure', () async {
    final error = StateError('mapper bug');
    final repository = ProfileRepositoryImpl(
      ProfileRemoteDataSource(_ThrowingProfileApi(error)),
    );

    await expectLater(repository.getProfile(), throwsA(same(error)));
  });
}

class _ThrowingProfileApi implements ProfileApi {
  const _ThrowingProfileApi(this.error);

  final Object error;

  @override
  Future<ProfileResponseDto> getProfile() async {
    throw error;
  }
}

DioException _dioException() {
  final request = RequestOptions(path: '/profile');
  return DioException(
    requestOptions: request,
    response: Response<void>(
      requestOptions: request,
      statusCode: 401,
    ),
  );
}
