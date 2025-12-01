
class AuthResponse {
  final String accessToken;
  final String refreshToken;

  AuthResponse({required this.accessToken, required this.refreshToken});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
    return data;
  }

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}