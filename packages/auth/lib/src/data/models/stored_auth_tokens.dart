class StoredAuthTokens {
  const StoredAuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.userId,
    this.accessTokenExpiresAt,
    this.refreshTokenExpiresAt,
  });

  factory StoredAuthTokens.fromJson(Map<String, Object?> json) {
    final accessToken = json['accessToken'];
    final refreshToken = json['refreshToken'];
    final userId = json['userId'];
    if (accessToken is! String || accessToken.isEmpty ||
        refreshToken is! String || refreshToken.isEmpty) {
      throw const FormatException('Invalid auth token pair');
    }
    return StoredAuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId is String && userId.isNotEmpty ? userId : null,
      accessTokenExpiresAt: _readDateTime(json['accessTokenExpiresAt']),
      refreshTokenExpiresAt: _readDateTime(json['refreshTokenExpiresAt']),
    );
  }

  final String accessToken;
  final String refreshToken;
  final String? userId;
  final DateTime? accessTokenExpiresAt;
  final DateTime? refreshTokenExpiresAt;

  bool get isRefreshTokenExpired {
    final expiresAt = refreshTokenExpiresAt;
    return expiresAt != null && !expiresAt.isAfter(DateTime.now().toUtc());
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'userId': userId,
        'accessTokenExpiresAt': accessTokenExpiresAt?.toUtc().toIso8601String(),
        'refreshTokenExpiresAt': refreshTokenExpiresAt?.toUtc().toIso8601String(),
      };

  static DateTime? _readDateTime(Object? value) {
    if (value == null) return null;
    if (value is! String) {
      throw const FormatException('Invalid token expiration');
    }
    return DateTime.tryParse(value)?.toUtc() ??
        (throw const FormatException('Invalid token expiration'));
  }

}
