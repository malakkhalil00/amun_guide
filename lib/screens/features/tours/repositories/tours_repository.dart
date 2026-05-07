import 'package:amin_gide/core/services/api_service.dart';
import 'package:amin_gide/features/tours/models/tour_model.dart';

class ToursRepository {
  final ApiService _apiService;

  ToursRepository(this._apiService);

  /// جلب كل الرحلات
  Future<List<TourModel>> getAllTours({int page = 1}) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        endpoint: '/v1/tours?page=$page',
        fromJson: (json) => (json as List)
            .map((item) => TourModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        includeAuth: false,
      );

      if (response.success && response.data != null) {
        return response.data as List<TourModel>;
      }
      throw ApiException(message: response.message ?? 'فشل جلب الرحلات');
    } catch (e) {
      rethrow;
    }
  }

  /// إضافة رحلة جديدة (للمرشدين)
  Future<TourModel> addTour(Map<String, dynamic> tourData) async {
    try {
      final response = await _apiService.post<TourModel>(
        endpoint: '/v1/tours',
        data: tourData,
        fromJson: (json) => TourModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ApiException(message: response.message ?? 'فشل إضافة الرحلة');
    } catch (e) {
      rethrow;
    }
  }

  /// حجز رحلة
  Future<bool> bookTour(int tourId, String date) async {
    try {
      final response = await _apiService.post(
        endpoint: '/v1/bookings',
        data: {'tour_id': tourId, 'booking_date': date},
        fromJson: (json) => json,
        includeAuth: true,
      );
      return response.success;
    } catch (e) {
      rethrow;
    }
  }
}