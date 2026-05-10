import 'package:amin_gide/features/tours/models/tour_model.dart';

class TourModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final String duration;
  final int? locationId;
  final int? guideId;
  final String? createdAt;
  final List<String> images; // قائمة الصور

  TourModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    this.locationId,
    this.guideId,
    this.createdAt,
    this.images = const [],
  });

  // تحويل الـ JSON القادم من الـ API إلى Object
  factory TourModel.fromJson(Map<String, dynamic> json) {
    return TourModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      // التعامل مع السعر سواء كان int أو double من الـ API
      price: (json['price'] is int) 
          ? (json['price'] as int).toDouble() 
          : (json['price'] ?? 0.0),
      duration: json['duration'] ?? '',
      locationId: json['location_id'],
      guideId: json['guide_id'],
      createdAt: json['created_at'],
      // تحويل قائمة الصور من JSON
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : [],
    );
  }

  // إذا احتجتِ تحويل الكائن مرة أخرى لـ JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'duration': duration,
      'location_id': locationId,
      'guide_id': guideId,
      'images': images,
    };
  }
}

/// موديل خاص بطلب إضافة رحلة جديدة (Request Body)
class TourRequestModel {
  final String title;
  final String description;
  final double price;
  final String duration;
  final int locationId;

  TourRequestModel({
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.locationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'duration': duration,
      'location_id': locationId,
    };
  }
}