class User {
  final int id;
  final String email;
  final String fullName;
  final String phone;
  final String address;
  final String profilePictureUrl;
  final String socialProvider;
  final String socialId;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.profilePictureUrl,
    required this.socialProvider,
    required this.socialId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id, 'email': email};
    return data;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? '',
      socialProvider: json['socialProvider'] ?? '',
      socialId: json['socialId'] ?? '',
    );
  }
}
