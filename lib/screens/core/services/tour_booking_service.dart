import 'package:dio/dio.dart';
import '../constants/Api.dart';
import 'dio_client.dart';

class TourBookingService {
  final _dio = DioClient().dio;

  /// Create a tour booking
  Future<Response> createBooking({
    required int tourId,
    required int participantsCount,
  }) async {
    return await _dio.post(Api.tourBookingsBase, data: {
      'tour_id': tourId,
      'participants_count': participantsCount,
    });
  }

  /// Get my bookings
  Future<Response> getMyBookings() async {
    return await _dio.get(Api.myBookings);
  }

  /// Get booking details
  Future<Response> getBookingDetails(int id) async {
    return await _dio.get(Api.tourBookingById(id));
  }

  /// Update a booking
  Future<Response> updateBooking(int id, {required int participantsCount}) async {
    return await _dio.put(Api.tourBookingById(id), data: {
      'participants_count': participantsCount,
    });
  }

  /// Cancel a booking
  Future<Response> cancelBooking(int id) async {
    return await _dio.delete(Api.tourBookingById(id));
  }

  /// Approve a booking (guide)
  Future<Response> approveBooking(int id) async {
    return await _dio.post(Api.tourBookingApprove(id));
  }

  /// Reject a booking (guide)
  Future<Response> rejectBooking(int id) async {
    return await _dio.post(Api.tourBookingReject(id));
  }

  /// Get all bookings (admin) with optional tour_id filter
  Future<Response> getAllBookings({int? tourId}) async {
    return await _dio.get(Api.tourBookingsBase, queryParameters: {
      if (tourId != null) 'tour_id': tourId,
    });
  }

  /// Booking statistics
  Future<Response> getStatistics() async {
    return await _dio.get(Api.tourBookingStatistics);
  }
}
