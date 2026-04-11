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
    return {'id': id, 'email': email};
  }

  static int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final id = _parseId(json['id']);
    if (id == null) {
      throw FormatException('Missing or invalid user id', json);
    }

    return User(
      id: id,
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      profilePictureUrl: json['profilePictureUrl']?.toString() ?? '',
      socialProvider: json['socialProvider']?.toString() ?? '',
      socialId: json['socialId']?.toString() ?? '',
    );
  }
}
