// Models for Profile Feature

class ProfileModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? bio;
  final String? avatar;
  final String? userType; // 'tourist', 'guide', 'admin'
  final String? city;
  final String? country;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.bio,
    this.avatar,
    this.userType,
    this.city,
    this.country,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      bio: json['bio'],
      avatar: json['avatar'],
      userType: json['user_type'],
      city: json['city'],
      country: json['country'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class ProfileUpdateModel {
  final String firstName;
  final String lastName;
  final String? phone;
  final String? bio;
  final String? city;
  final String? country;

  ProfileUpdateModel({
    required this.firstName,
    required this.lastName,
    this.phone,
    this.bio,
    this.city,
    this.country,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'bio': bio,
        'city': city,
        'country': country,
      };
}
