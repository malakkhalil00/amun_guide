// Models for Booking Feature

class BookingModel {
  final int id;
  final int tourId;
  final int userId;
  final int numberOfPeople;
  final double totalPrice;
  final String status; // 'pending', 'approved', 'rejected', 'completed'
  final String? notes;
  final DateTime bookingDate;
  final DateTime tourDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? tour; // Nested tour data
  final Map<String, dynamic>? user; // Nested user data

  BookingModel({
    required this.id,
    required this.tourId,
    required this.userId,
    required this.numberOfPeople,
    required this.totalPrice,
    required this.status,
    this.notes,
    required this.bookingDate,
    required this.tourDate,
    required this.createdAt,
    required this.updatedAt,
    this.tour,
    this.user,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? 0,
      tourId: json['tour_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      numberOfPeople: json['number_of_people'] ?? 0,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      bookingDate:
          DateTime.tryParse(json['booking_date'] ?? '') ?? DateTime.now(),
      tourDate: DateTime.tryParse(json['tour_date'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      tour: json['tour'],
      user: json['user'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tour_id': tourId,
        'user_id': userId,
        'number_of_people': numberOfPeople,
        'total_price': totalPrice,
        'status': status,
        'notes': notes,
        'booking_date': bookingDate.toIso8601String(),
        'tour_date': tourDate.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'tour': tour,
        'user': user,
      };
}

class BookingRequestModel {
  final int tourId;
  final int numberOfPeople;
  final DateTime tourDate;
  final String? notes;

  BookingRequestModel({
    required this.tourId,
    required this.numberOfPeople,
    required this.tourDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'tour_id': tourId,
        'number_of_people': numberOfPeople,
        'tour_date': tourDate.toIso8601String(),
        'notes': notes,
      };
}
