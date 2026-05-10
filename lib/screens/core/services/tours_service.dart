import 'package:dio/dio.dart';
import '../constants/Api.dart';
import 'dio_client.dart';

class ToursService {
  final _dio = DioClient().dio;

  /// Get all tours with optional pagination, sort, and guide filter
  Future<Response> getAllTours({
    int? page,
    int? perPage,
    String? sort,
    int? guideId,
  }) async {
    return await _dio.get(Api.tours, queryParameters: {
      if (page != null) 'page': page,
      if (perPage != null) 'per_page': perPage,
      if (sort != null) 'sort': sort,
      if (guideId != null) 'guide_id': guideId,
    });
  }

  /// Get tour details
  Future<Response> getTour(int id) async {
    return await _dio.get(Api.tourById(id));
  }

  /// Create a new tour
  Future<Response> createTour(Map<String, dynamic> data) async {
    return await _dio.post(Api.tours, data: data);
  }

  /// Update a tour
  Future<Response> updateTour(int id, Map<String, dynamic> data) async {
    return await _dio.put(Api.tourById(id), data: data);
  }

  /// Delete a tour
  Future<Response> deleteTour(int id) async {
    return await _dio.delete(Api.tourById(id));
  }

  /// Get my tours (guide)
  Future<Response> getMyTours() async {
    return await _dio.get(Api.myTours);
  }

  /// Search tours
  Future<Response> searchTours(String query) async {
    return await _dio.get(Api.searchTours, queryParameters: {'q': query});
  }

  /// Filter tours by price range
  Future<Response> filterTours({double? minPrice, double? maxPrice}) async {
    return await _dio.get(Api.filterTours, queryParameters: {
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
    });
  }

  /// Get popular tours
  Future<Response> getPopularTours() async {
    return await _dio.get(Api.popularTours);
  }

  /// Get tours by guide
  Future<Response> getGuideTours(int guideId) async {
    return await _dio.get(Api.guideTours(guideId));
  }

  /// Get tour bookings
  Future<Response> getTourBookings(int tourId) async {
    return await _dio.get(Api.tourBookings(tourId));
  }
}
