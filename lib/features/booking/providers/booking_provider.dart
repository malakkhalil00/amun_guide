import 'package:flutter/foundation.dart';
import 'package:amin_gide/features/booking/models/booking_models.dart';
import 'package:amin_gide/features/booking/repositories/booking_repository.dart';

/// Booking Provider
class BookingProvider extends ChangeNotifier {
  final BookingRepository _repository;

  BookingProvider(this._repository);

  // State
  List<BookingModel> _myBookings = [];
  List<BookingModel> _allBookings = [];
  BookingModel? _selectedBooking;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _statistics;

  // Getters
  List<BookingModel> get myBookings => _myBookings;
  List<BookingModel> get allBookings => _allBookings;
  BookingModel? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get statistics => _statistics;

  // Load my bookings
  Future<void> loadMyBookings({int page = 1, int perPage = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myBookings = await _repository.getMyBookings(
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

  // Get booking details
  Future<void> loadBooking(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedBooking = await _repository.getBooking(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create booking
  Future<void> createBooking(BookingRequestModel request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final booking = await _repository.createBooking(request);
      _myBookings.insert(0, booking);
      _selectedBooking = booking;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel booking
  Future<void> cancelBooking(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.cancelBooking(id);
      _myBookings.removeWhere((b) => b.id == id);
      if (_selectedBooking?.id == id) {
        _selectedBooking = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all bookings (Admin)
  Future<void> loadAllBookings({int page = 1, int perPage = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allBookings = await _repository.getAllBookings(
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

  // Approve booking
  Future<void> approveBooking(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.approveBooking(id);
      _updateBookingInList(updated);
      _selectedBooking = updated;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reject booking
  Future<void> rejectBooking(int id, {String? reason}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.rejectBooking(id, reason: reason);
      _updateBookingInList(updated);
      _selectedBooking = updated;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load statistics
  Future<void> loadStatistics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _statistics = await _repository.getBookingStatistics();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper to update booking in lists
  void _updateBookingInList(BookingModel booking) {
    final myIndex = _myBookings.indexWhere((b) => b.id == booking.id);
    if (myIndex != -1) {
      _myBookings[myIndex] = booking;
    }

    final allIndex = _allBookings.indexWhere((b) => b.id == booking.id);
    if (allIndex != -1) {
      _allBookings[allIndex] = booking;
    }
  }

  // Clear state
  void clear() {
    _myBookings = [];
    _allBookings = [];
    _selectedBooking = null;
    _errorMessage = null;
    _statistics = null;
    notifyListeners();
  }
}
