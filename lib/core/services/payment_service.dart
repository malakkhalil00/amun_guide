import 'package:dio/dio.dart';
import '../constants/Api.dart';
import 'dio_client.dart';

class PaymentService {
  final _dio = DioClient().dio;

  /// Store a new payment with receipt image
  Future<Response> storePayment({
    required double amount,
    required String payableType,
    required int payableId,
    String? receiptImageUrl,
    String? notes,
  }) async {
    return await _dio.post(
      Api.payments,
      data: {
        'amount': amount,
        'payable_type': payableType,
        'payable_id': payableId,
        if (receiptImageUrl != null) 'receipt_image': receiptImageUrl,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
  }

  /// Get my payments
  Future<Response> getMyPayments() async {
    return await _dio.get(Api.myPayments);
  }

  /// Get payment details
  Future<Response> getPaymentDetails(int id) async {
    return await _dio.get(Api.paymentById(id));
  }

  /// Update payment (with optional receipt image)
  Future<Response> updatePayment(
    int id, {
    String? notes,
    String? receiptImagePath,
  }) async {
    final formData = FormData.fromMap({
      '_method': 'PUT',
      if (notes != null) 'notes': notes,
      if (receiptImagePath != null)
        'receipt_image': await MultipartFile.fromFile(
          receiptImagePath,
          filename: 'receipt.jpg',
        ),
    });
    return await _dio.post(Api.paymentById(id), data: formData);
  }

  // ══════════════════════════════════════
  // ADMIN ENDPOINTS
  // ══════════════════════════════════════

  /// Get all payments (admin)
  Future<Response> getAllPayments() async {
    return await _dio.get(Api.payments);
  }

  /// Approve a payment
  Future<Response> approvePayment(int id) async {
    return await _dio.post(Api.paymentApprove(id));
  }

  /// Reject a payment
  Future<Response> rejectPayment(int id) async {
    return await _dio.post(Api.paymentReject(id));
  }

  /// Delete a payment
  Future<Response> deletePayment(int id) async {
    return await _dio.delete(Api.paymentById(id));
  }

  /// Bulk approve payments
  Future<Response> bulkApprove(List<int> paymentIds) async {
    return await _dio.post(
      Api.paymentBulkApprove,
      data: {'payment_ids': paymentIds},
    );
  }

  /// Get user's payments (admin)
  Future<Response> getUserPayments(int userId) async {
    return await _dio.get(Api.userPayments(userId));
  }

  /// Payment statistics (admin)
  Future<Response> getStatistics() async {
    return await _dio.get(Api.paymentStatistics);
  }

  /// Update payment status/amount (admin PATCH)
  Future<Response> patchPayment(int id, Map<String, dynamic> data) async {
    return await _dio.patch(Api.paymentById(id), data: data);
  }
}
