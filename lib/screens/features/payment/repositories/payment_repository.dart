import 'package:amin_gide/core/services/api_service.dart';
import 'package:amin_gide/features/payment/models/payment_models.dart';

/// Payment Repository
class PaymentRepository {
  final ApiService _apiService;

  PaymentRepository(this._apiService);

  /// Get my payments
  Future<List<PaymentModel>> getMyPayments({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        endpoint: '/v1/payments/my-payments?page=$page&per_page=$perPage',
        fromJson: (json) => (json as List)
            .map((item) => PaymentModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data as List<PaymentModel>;
      }

      throw ApiException(
        message: response.message ?? 'Failed to fetch payments',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get payment by id
  Future<PaymentModel> getPayment(int id) async {
    try {
      final response = await _apiService.get<PaymentModel>(
        endpoint: '/v1/payments/$id',
        fromJson: (json) => PaymentModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to fetch payment',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create payment
  Future<PaymentModel> createPayment(PaymentRequestModel request) async {
    try {
      final response = await _apiService.post<PaymentModel>(
        endpoint: '/v1/payments',
        data: request.toJson(),
        fromJson: (json) => PaymentModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to create payment',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get all payments (Admin)
  Future<List<PaymentModel>> getAllPayments({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        endpoint: '/v1/payments?page=$page&per_page=$perPage',
        fromJson: (json) => (json as List)
            .map((item) => PaymentModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data as List<PaymentModel>;
      }

      throw ApiException(
        message: response.message ?? 'Failed to fetch payments',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Approve payment (Admin)
  Future<PaymentModel> approvePayment(int id) async {
    try {
      final response = await _apiService.post<PaymentModel>(
        endpoint: '/v1/payments/$id/approve',
        data: {},
        fromJson: (json) => PaymentModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to approve payment',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Reject payment (Admin)
  Future<PaymentModel> rejectPayment(int id, {String? reason}) async {
    try {
      final response = await _apiService.post<PaymentModel>(
        endpoint: '/v1/payments/$id/reject',
        data: {'reason': reason},
        fromJson: (json) => PaymentModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to reject payment',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get payment statistics (Admin)
  Future<Map<String, dynamic>> getPaymentStatistics() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: '/v1/payments/statistics',
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
