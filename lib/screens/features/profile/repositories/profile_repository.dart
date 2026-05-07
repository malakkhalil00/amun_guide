import 'package:amin_gide/core/services/api_service.dart';
import 'package:amin_gide/features/profile/models/profile_models.dart';

/// Profile Repository
class ProfileRepository {
  final ApiService _apiService;

  ProfileRepository(this._apiService);

  /// Get current user profile
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _apiService.get<ProfileModel>(
        endpoint: '/user',
        fromJson: (json) => ProfileModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to fetch profile',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update profile
  Future<ProfileModel> updateProfile(ProfileUpdateModel request) async {
    try {
      final response = await _apiService.put<ProfileModel>(
        endpoint: '/v1/profile',
        data: request.toJson(),
        fromJson: (json) => ProfileModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to update profile',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }
}
