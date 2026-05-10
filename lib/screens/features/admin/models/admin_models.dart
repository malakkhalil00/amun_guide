// Models for Admin Feature

class AdminStatsModel {
  final int totalUsers;
  final int totalTours;
  final int totalPlaces;
  final int totalBookings;
  final int pendingPayments;
  final int approvedPayments;
  final double totalRevenue;
  final double averageRating;

  AdminStatsModel({
    required this.totalUsers,
    required this.totalTours,
    required this.totalPlaces,
    required this.totalBookings,
    required this.pendingPayments,
    required this.approvedPayments,
    required this.totalRevenue,
    required this.averageRating,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalUsers: json['total_users'] ?? 0,
      totalTours: json['total_tours'] ?? 0,
      totalPlaces: json['total_places'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
      pendingPayments: json['pending_payments'] ?? 0,
      approvedPayments: json['approved_payments'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      averageRating: (json['average_rating'] ?? 0).toDouble(),
    );
  }
}

class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? userType; // 'tourist', 'guide', 'admin'
  final String? avatar;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.userType,
    this.avatar,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      userType: json['user_type'],
      avatar: json['avatar'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
