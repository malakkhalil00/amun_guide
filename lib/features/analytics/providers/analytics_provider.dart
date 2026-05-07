import 'package:flutter/foundation.dart';
import 'package:amin_gide/features/analytics/models/analytics_models.dart';
import 'package:amin_gide/features/analytics/repositories/analytics_repository.dart';

/// Analytics Provider
class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsRepository _repository;

  AnalyticsProvider(this._repository);

  // State
  UserActivityModel? _userActivity;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserActivityModel? get userActivity => _userActivity;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load user activity
  Future<void> loadUserActivity() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userActivity = await _repository.getUserActivity();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear state
  void clear() {
    _userActivity = null;
    _errorMessage = null;
    notifyListeners();
  }
}
