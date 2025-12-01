class SignInRequest {
  final String email;
  final String password;

  // Shorthand Constructor
  const SignInRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'password': password,
    };
    return data;
  }
}