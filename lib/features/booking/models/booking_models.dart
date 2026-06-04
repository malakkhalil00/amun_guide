// 📁 lib/features/booking/models/booking_models.dart

class BookingModel {
  final String id;
  final String tourId;
  final String tourName;
  final String guideName;
  final String? tourImageUrl;
  final String? location;
  final int durationDays;
  final double pricePerPerson;
  final int travelerCount;
  final DateTime selectedDate;
  final String status; // pending | approved | rejected
  final String? meetingPoint;
  final String? paymentStatus;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.tourId,
    required this.tourName,
    required this.guideName,
    this.tourImageUrl,
    this.location,
    required this.durationDays,
    required this.pricePerPerson,
    required this.travelerCount,
    required this.selectedDate,
    required this.status,
    this.meetingPoint,
    this.paymentStatus,
    required this.createdAt,
  });

  double get totalPrice => pricePerPerson * travelerCount;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      tourId: json['tour_id']?.toString() ?? json['tourId']?.toString() ?? '',
      tourName: json['tour_name'] ?? json['tourName'] ?? '',
      guideName: json['guide_name'] ?? json['guideName'] ?? '',
      tourImageUrl: json['tour_image_url'] ?? json['tourImageUrl'],
      location: json['location'],
      durationDays: json['duration_days'] ?? json['durationDays'] ?? 1,
      pricePerPerson:
          (json['price_per_person'] ?? json['pricePerPerson'] ?? 0).toDouble(),
      travelerCount: json['traveler_count'] ?? json['travelerCount'] ?? 1,
      selectedDate: DateTime.tryParse(
              json['selected_date'] ?? json['selectedDate'] ?? '') ??
          DateTime.now(),
      status: json['status'] ?? 'pending',
      meetingPoint: json['meeting_point'] ?? json['meetingPoint'],
      paymentStatus: json['payment_status'] ?? json['paymentStatus'],
      createdAt:
          DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'tour_id': tourId,
        'traveler_count': travelerCount,
        'selected_date': selectedDate.toIso8601String(),
      };
}

// ── Request model (used when creating a new booking) ──────────────────────────
class BookingRequestModel {
  final String tourId;
  final int travelerCount;
  final DateTime selectedDate;

  const BookingRequestModel({
    required this.tourId,
    required this.travelerCount,
    required this.selectedDate,
  });

  Map<String, dynamic> toJson() => {
        'tour_id': tourId,
        'traveler_count': travelerCount,
        'selected_date': selectedDate.toIso8601String(),
      };
}