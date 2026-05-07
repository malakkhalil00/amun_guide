import 'package:flutter/foundation.dart';
import 'package:amin_gide/features/admin/models/admin_models.dart';
import 'package:amin_gide/features/admin/repositories/admin_repository.dart';

/// Admin Provider
class AdminProvider extends ChangeNotifier {
  final AdminRepository _repository;

  AdminProvider(this._repository);

  // State
  AdminStatsModel? _stats;
  List<UserModel> _users = [];
  Map<String, dynamic>? _userAnalysis;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  AdminStatsModel? get stats => _stats;
  List<UserModel> get users => _users;
  Map<String, dynamic>? get userAnalysis => _userAnalysis;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load stats
  Future<void> loadStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stats = await _repository.getStats();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load users
  Future<void> loadUsers({int page = 1, int perPage = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _repository.getUsers(page: page, perPage: perPage);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user analysis
  Future<void> loadUserAnalysis() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userAnalysis = await _repository.getUserAnalysis();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear state
  void clear() {
    _stats = null;
    _users = [];
    _userAnalysis = null;
    _errorMessage = null;
    notifyListeners();
  }
}
