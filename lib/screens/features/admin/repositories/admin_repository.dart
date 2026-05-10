import 'package:amin_gide/core/services/api_service.dart';
import 'package:amin_gide/features/admin/models/admin_models.dart';

/// Admin Repository
class AdminRepository {
  final ApiService _apiService;

  AdminRepository(this._apiService);

  /// Get admin stats
  Future<AdminStatsModel> getStats() async {
    try {
      final response = await _apiService.get<AdminStatsModel>(
        endpoint: '/v1/admin/stats',
        fromJson: (json) => AdminStatsModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to fetch stats',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get all users
  Future<List<UserModel>> getUsers({int page = 1, int perPage = 20}) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        endpoint: '/v1/users?page=$page&per_page=$perPage',
        fromJson: (json) => (json as List)
            .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data as List<UserModel>;
      }

      throw ApiException(
        message: response.message ?? 'Failed to fetch users',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get user analysis
  Future<Map<String, dynamic>> getUserAnalysis() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: '/v1/analysis/users-all',
        fromJson: (json) => json,
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to fetch analysis',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }
}
