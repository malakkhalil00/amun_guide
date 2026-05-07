import 'package:amin_gide/core/services/api_service.dart';
import 'package:amin_gide/features/notification/models/notification_models.dart';

/// Notification Repository
class NotificationRepository {
  final ApiService _apiService;

  NotificationRepository(this._apiService);

  /// Get notifications
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        endpoint: '/v1/notifications?page=$page&per_page=$perPage',
        fromJson: (json) => (json as List)
            .map((item) =>
                NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data as List<NotificationModel>;
      }

      throw ApiException(
        message: response.message ?? 'Failed to fetch notifications',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(int id) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: '/v1/notifications/$id/read',
        data: {},
        fromJson: (json) => json,
        includeAuth: true,
      );

      if (!response.success) {
        throw ApiException(
          message: response.message ?? 'Failed to mark notification as read',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: '/v1/notifications/read-all',
        data: {},
        fromJson: (json) => json,
        includeAuth: true,
      );

      if (!response.success) {
        throw ApiException(
          message: response.message ?? 'Failed to mark all as read',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
