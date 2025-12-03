
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
    final Map<String, dynamic> data = {
      'id': id,
      'email': email,
    };
    return data;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String,
      socialProvider: json['socialProvider'] as String,
      socialId: json['socialId'] as String,
    );
  }
}