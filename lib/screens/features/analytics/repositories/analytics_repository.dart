import 'package:amin_gide/core/services/api_service.dart';
import 'package:amin_gide/features/analytics/models/analytics_models.dart';

/// Analytics Repository
class AnalyticsRepository {
  final ApiService _apiService;

  AnalyticsRepository(this._apiService);

  /// Get user activity
  Future<UserActivityModel> getUserActivity() async {
    try {
      final response = await _apiService.post<UserActivityModel>(
        endpoint: '/v1/analysis/user_activity',
        data: {},
        fromJson: (json) => UserActivityModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to fetch user activity',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }
}
