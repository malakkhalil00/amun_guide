// Models for Analytics Feature

class AnalyticsModel {
  final int id;
  final int userId;
  final String
      eventType; // 'place_view', 'tour_view', 'booking', 'payment', etc.
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  AnalyticsModel({
    required this.id,
    required this.userId,
    required this.eventType,
    this.metadata,
    required this.createdAt,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      eventType: json['event_type'] ?? '',
      metadata: json['metadata'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class UserActivityModel {
  final int totalViews;
  final int totalBookings;
  final int totalPayments;
  final int totalComments;
  final List<String> favoriteCategories;

  UserActivityModel({
    required this.totalViews,
    required this.totalBookings,
    required this.totalPayments,
    required this.totalComments,
    required this.favoriteCategories,
  });

  factory UserActivityModel.fromJson(Map<String, dynamic> json) {
    return UserActivityModel(
      totalViews: json['total_views'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
      totalPayments: json['total_payments'] ?? 0,
      totalComments: json['total_comments'] ?? 0,
      favoriteCategories: List<String>.from(json['favorite_categories'] ?? []),
    );
  }
}
