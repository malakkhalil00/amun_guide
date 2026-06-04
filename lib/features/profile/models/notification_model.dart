// 📁 lib/features/profile/models/notification_model.dart
enum NotificationType {
  booking,    // Booking confirmations
  tour,       // Tour reminders
  message,    // New messages
  offer,      // Offers & promotions
  system,     // System alerts
}

class NotificationModel {
  final int id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id:        id,
      type:      type,
      title:     title,
      body:      body,
      createdAt: createdAt,
      isRead:    isRead ?? this.isRead,
    );
  }

  // TODO: لما الـ API يجهز — uncomment
  // factory NotificationModel.fromJson(Map<String, dynamic> json) {
  //   return NotificationModel(
  //     id:        json['id'],
  //     type:      _typeFromString(json['type']),
  //     title:     json['title'],
  //     body:      json['body'],
  //     createdAt: DateTime.parse(json['created_at']),
  //     isRead:    json['is_read'] ?? false,
  //   );
  // }

  // static NotificationType _typeFromString(String type) {
  //   switch (type) {
  //     case 'booking': return NotificationType.booking;
  //     case 'tour':    return NotificationType.tour;
  //     case 'message': return NotificationType.message;
  //     case 'offer':   return NotificationType.offer;
  //     default:        return NotificationType.system;
  //   }
  // }
}