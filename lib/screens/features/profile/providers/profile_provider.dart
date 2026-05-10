import 'package:flutter/foundation.dart';
import 'package:amin_gide/features/profile/models/profile_models.dart';
import 'package:amin_gide/features/profile/repositories/profile_repository.dart';

/// Profile Provider
class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileProvider(this._repository);

  // State
  ProfileModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load profile
  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.getProfile();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile
  Future<void> updateProfile(ProfileUpdateModel request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.updateProfile(request);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear state
  void clear() {
    _profile = null;
    _errorMessage = null;
    notifyListeners();
  }
}
