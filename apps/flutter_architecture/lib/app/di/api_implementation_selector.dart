import 'package:api_client/api_client.dart' as api_client;
import 'package:dio/dio.dart';
import 'package:flutter_architecture/app/config/api_config.dart';

/// 依 App API 設定選擇 Mock 或 Retrofit implementation。
///
/// 選擇邏輯留在 App Composition Root，不放進可重用 package。
abstract final class ApiImplementationSelector {
  static api_client.AuthApi createAuthApi(ApiConfig config, Dio dio) {
    return switch (config.mode) {
      ApiMode.mock => const api_client.MockAuthApi(),
      ApiMode.real => api_client.AuthApi(dio),
    };
  }

  static api_client.AuthRefreshApi createAuthRefreshApi(
    ApiConfig config,
    Dio dio,
  ) {
    return switch (config.mode) {
      ApiMode.mock => const api_client.MockAuthRefreshApi(),
      ApiMode.real => api_client.AuthRefreshApi(dio),
    };
  }

  static api_client.ProfileApi createProfileApi(ApiConfig config, Dio dio) {
    return switch (config.mode) {
      ApiMode.mock => const api_client.MockProfileApi(),
      ApiMode.real => api_client.ProfileApi(dio),
    };
  }
}
