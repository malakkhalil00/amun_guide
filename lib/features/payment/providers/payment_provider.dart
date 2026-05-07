import 'package:flutter/foundation.dart';
import 'package:amin_gide/features/payment/models/payment_models.dart';
import 'package:amin_gide/features/payment/repositories/payment_repository.dart';

/// Payment Provider
class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repository;

  PaymentProvider(this._repository);

  // State
  List<PaymentModel> _myPayments = [];
  List<PaymentModel> _allPayments = [];
  PaymentModel? _selectedPayment;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _statistics;

  // Getters
  List<PaymentModel> get myPayments => _myPayments;
  List<PaymentModel> get allPayments => _allPayments;
  PaymentModel? get selectedPayment => _selectedPayment;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get statistics => _statistics;

  // Load my payments
  Future<void> loadMyPayments({int page = 1, int perPage = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myPayments = await _repository.getMyPayments(
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get payment details
  Future<void> loadPayment(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedPayment = await _repository.getPayment(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create payment
  Future<void> createPayment(PaymentRequestModel request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payment = await _repository.createPayment(request);
      _myPayments.insert(0, payment);
      _selectedPayment = payment;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all payments (Admin)
  Future<void> loadAllPayments({int page = 1, int perPage = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allPayments = await _repository.getAllPayments(
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Approve payment (Admin)
  Future<void> approvePayment(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.approvePayment(id);
      _updatePaymentInList(updated);
      _selectedPayment = updated;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reject payment (Admin)
  Future<void> rejectPayment(int id, {String? reason}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.rejectPayment(id, reason: reason);
      _updatePaymentInList(updated);
      _selectedPayment = updated;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load statistics (Admin)
  Future<void> loadStatistics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _statistics = await _repository.getPaymentStatistics();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper to update payment in lists
  void _updatePaymentInList(PaymentModel payment) {
    final myIndex = _myPayments.indexWhere((p) => p.id == payment.id);
    if (myIndex != -1) {
      _myPayments[myIndex] = payment;
    }

    final allIndex = _allPayments.indexWhere((p) => p.id == payment.id);
    if (allIndex != -1) {
      _allPayments[allIndex] = payment;
    }
  }

  // Clear state
  void clear() {
    _myPayments = [];
    _allPayments = [];
    _selectedPayment = null;
    _errorMessage = null;
    _statistics = null;
    notifyListeners();
  }
}
