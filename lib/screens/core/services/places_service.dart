import 'package:dio/dio.dart';
import '../constants/Api.dart';
import 'dio_client.dart';

class PlacesService {
  final _dio = DioClient().dio;

  /// Get all places
  Future<Response> getAllPlaces() async {
    return await _dio.get(Api.places);
  }

  /// Get place details by ID
  Future<Response> getPlace(int id) async {
    return await _dio.get(Api.placeById(id));
  }

  /// Store a new place (admin — formdata for image upload)
  Future<Response> storePlace({
    required String title,
    required String description,
    required double ticketPrice,
    required double rating,
    String? imagePath,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'description': description,
      'ticket_price': ticketPrice,
      'rating': rating,
      if (imagePath != null)
        'image': await MultipartFile.fromFile(imagePath, filename: 'place.jpg'),
    });
    return await _dio.post(Api.places, data: formData);
  }

  /// Update a place
  Future<Response> updatePlace(int id, Map<String, dynamic> data) async {
    return await _dio.put(Api.placeById(id), data: data);
  }

  /// Delete a place
  Future<Response> deletePlace(int id) async {
    return await _dio.delete(Api.placeById(id));
  }

  /// Get trending places
  Future<Response> getTrendingPlaces() async {
    return await _dio.get(Api.trendingPlaces);
  }

  /// Filter places by min/max price
  Future<Response> filterPlaces({double? minPrice, double? maxPrice}) async {
    return await _dio.get(Api.filterPlaces, queryParameters: {
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
    });
  }

  /// Search places by query
  Future<Response> searchPlaces(String query) async {
    return await _dio.get(Api.searchPlaces, queryParameters: {'q': query});
  }

  /// Get comments for a place
  Future<Response> getPlaceComments(int placeId) async {
    return await _dio.get(Api.subjectComments('places', placeId));
  }

  /// Get likes for a place
  Future<Response> getPlaceLikes(int placeId) async {
    return await _dio.get(Api.subjectLikes('places', placeId));
  }

  /// Get likes count for a place
  Future<Response> getPlaceLikesCount(int placeId) async {
    return await _dio.get(Api.subjectLikesCount('places', placeId));
  }

  /// Get comments count for a place
  Future<Response> getPlaceCommentsCount(int placeId) async {
    return await _dio.get(Api.subjectCommentsCount('places', placeId));
  }
}
