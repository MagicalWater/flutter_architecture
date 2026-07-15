class StoredAuthTokens {
  const StoredAuthTokens({required this.accessToken, required this.refreshToken});

  factory StoredAuthTokens.fromJson(Map<String, Object?> json) {
    final accessToken = json['accessToken'];
    final refreshToken = json['refreshToken'];
    if (accessToken is! String || accessToken.isEmpty ||
        refreshToken is! String || refreshToken.isEmpty) {
      throw const FormatException('Invalid auth token pair');
    }
    return StoredAuthTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  final String accessToken;
  final String refreshToken;

  Map<String, Object?> toJson() => <String, Object?>{
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };

}
