import 'package:api_client/api_client.dart';
import 'package:auth/src/data/data_sources/auth_local_data_source.dart';
import 'package:injectable/injectable.dart';

/// Dio interceptor 使用的 token provider 實作。
///
/// ## Runtime Flow
///
/// ```txt
/// Dio request
///   ↓
/// AuthHeaderInterceptor
///   ↓
/// AuthTokenProvider
///   ↓
/// AuthTokenProviderImpl  ← 目前所在位置
///   ↓
/// AuthLocalDataSource
///   ↓
/// SharedPreferences
/// ```
@LazySingleton(as: AuthTokenProvider)
class AuthTokenProviderImpl implements AuthTokenProvider {
  const AuthTokenProviderImpl(this._localDataSource);

  final AuthLocalDataSource _localDataSource;

  @override
  Future<String?> getAccessToken() {
    return _localDataSource.readAccessToken();
  }
}
