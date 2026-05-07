import 'package:amin_gide/core/services/api_service.dart';
import 'package:amin_gide/features/booking/models/booking_models.dart';

/// Booking Repository
class BookingRepository {
  final ApiService _apiService;

  BookingRepository(this._apiService);

  /// Get my bookings
  Future<List<BookingModel>> getMyBookings({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        endpoint: '/v1/tour-bookings/my-bookings?page=$page&per_page=$perPage',
        fromJson: (json) => (json as List)
            .map((item) => BookingModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data as List<BookingModel>;
      }

      throw ApiException(
        message: response.message ?? 'Failed to fetch bookings',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get booking by id
  Future<BookingModel> getBooking(int id) async {
    try {
      final response = await _apiService.get<BookingModel>(
        endpoint: '/v1/tour-bookings/$id',
        fromJson: (json) => BookingModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to fetch booking',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create booking
  Future<BookingModel> createBooking(BookingRequestModel request) async {
    try {
      final response = await _apiService.post<BookingModel>(
        endpoint: '/v1/tour-bookings',
        data: request.toJson(),
        fromJson: (json) => BookingModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to create booking',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel booking
  Future<void> cancelBooking(int id) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        endpoint: '/v1/tour-bookings/$id',
        fromJson: (json) => json,
        includeAuth: true,
      );

      if (!response.success) {
        throw ApiException(
          message: response.message ?? 'Failed to cancel booking',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get all bookings (Admin)
  Future<List<BookingModel>> getAllBookings({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        endpoint: '/v1/tour-bookings?page=$page&per_page=$perPage',
        fromJson: (json) => (json as List)
            .map((item) => BookingModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data as List<BookingModel>;
      }

      throw ApiException(
        message: response.message ?? 'Failed to fetch bookings',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Approve booking (Guide/Admin)
  Future<BookingModel> approveBooking(int id) async {
    try {
      final response = await _apiService.post<BookingModel>(
        endpoint: '/v1/tour-bookings/$id/approve',
        data: {},
        fromJson: (json) => BookingModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to approve booking',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Reject booking (Guide/Admin)
  Future<BookingModel> rejectBooking(int id, {String? reason}) async {
    try {
      final response = await _apiService.post<BookingModel>(
        endpoint: '/v1/tour-bookings/$id/reject',
        data: {'reason': reason},
        fromJson: (json) => BookingModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to reject booking',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get booking statistics
  Future<Map<String, dynamic>> getBookingStatistics() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: '/v1/tour-bookings/statistics',
        fromJson: (json) => json,
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to fetch statistics',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }
}
