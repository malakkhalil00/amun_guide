import 'package:dio/dio.dart';
import 'dio_client.dart';

/// API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'ApiException: $message (StatusCode: $statusCode)';
}

/// API Response Model
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });
}

/// API Service - Wrapper on DioClient
class ApiService {
  final DioClient _dioClient = DioClient();

  /// Generic GET request
  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    required T Function(dynamic) fromJson,
    Map<String, dynamic>? queryParameters,
    bool includeAuth = false,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<T>(
          success: true,
          data: fromJson(response.data),
          statusCode: response.statusCode,
        );
      }

      throw ApiException(
        message: response.data['message'] ?? 'Unknown error',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Generic POST request
  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    required dynamic data,
    required T Function(dynamic) fromJson,
    bool includeAuth = false,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        endpoint,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<T>(
          success: true,
          data: fromJson(response.data),
          statusCode: response.statusCode,
        );
      }

      throw ApiException(
        message: response.data['message'] ?? 'Unknown error',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Generic PUT request
  Future<ApiResponse<T>> put<T>({
    required String endpoint,
    required dynamic data,
    required T Function(dynamic) fromJson,
    bool includeAuth = false,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        endpoint,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<T>(
          success: true,
          data: fromJson(response.data),
          statusCode: response.statusCode,
        );
      }

      throw ApiException(
        message: response.data['message'] ?? 'Unknown error',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Generic DELETE request
  Future<ApiResponse<T>> delete<T>({
    required String endpoint,
    required T Function(dynamic) fromJson,
    bool includeAuth = false,
  }) async {
    try {
      final response = await _dioClient.dio.delete(endpoint);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<T>(
          success: true,
          data: fromJson(response.data),
          statusCode: response.statusCode,
        );
      }

      throw ApiException(
        message: response.data['message'] ?? 'Unknown error',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      rethrow;
    }
  }
}