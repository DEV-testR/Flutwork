class AuthResponse {
  final String accessToken;
  final String refreshToken;

  /// Optional user payload from the login response (when not HttpOnly-only).
  final Map<String, dynamic>? user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      if (user != null) 'user': user,
    };
  }

  /// Parses token fields from camelCase or snake_case JSON; [user] if present.
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final access = json['accessToken'] ?? json['access_token'];
    final refresh = json['refreshToken'] ?? json['refresh_token'];

    if (access is! String || access.isEmpty) {
      throw FormatException(
        'Missing or invalid accessToken in auth response',
        json,
      );
    }

    final refreshStr = refresh is String ? refresh : '';

    Map<String, dynamic>? userMap;
    final rawUser = json['user'];
    if (rawUser is Map) {
      userMap = Map<String, dynamic>.from(rawUser);
    }

    return AuthResponse(
      accessToken: access,
      refreshToken: refreshStr,
      user: userMap,
    );
  }
}
