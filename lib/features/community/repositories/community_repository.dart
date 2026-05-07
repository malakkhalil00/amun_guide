import 'package:amin_gide/core/services/api_service.dart';
import 'package:amin_gide/features/community/models/community_models.dart';

/// Community Repository (Comments + Likes)
class CommunityRepository {
  final ApiService _apiService;

  CommunityRepository(this._apiService);

  /// Get comments for type
  Future<List<CommentModel>> getComments(String type, int id,
      {int page = 1}) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        endpoint: '/v1/comments/$type/$id?page=$page',
        fromJson: (json) => (json as List)
            .map((item) => CommentModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        includeAuth: false,
      );

      if (response.success && response.data != null) {
        return response.data as List<CommentModel>;
      }

      throw ApiException(
        message: response.message ?? 'Failed to fetch comments',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Add comment
  Future<CommentModel> addComment(CommentRequestModel request) async {
    try {
      final response = await _apiService.post<CommentModel>(
        endpoint: '/v1/comments',
        data: request.toJson(),
        fromJson: (json) => CommentModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to add comment',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update comment
  Future<CommentModel> updateComment(
      int id, CommentRequestModel request) async {
    try {
      final response = await _apiService.put<CommentModel>(
        endpoint: '/v1/comments/$id',
        data: request.toJson(),
        fromJson: (json) => CommentModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to update comment',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete comment
  Future<void> deleteComment(int id) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        endpoint: '/v1/comments/$id',
        fromJson: (json) => json,
        includeAuth: true,
      );

      if (!response.success) {
        throw ApiException(
          message: response.message ?? 'Failed to delete comment',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle like
  Future<LikeModel> toggleLike(String type, int typeId) async {
    try {
      final response = await _apiService.post<LikeModel>(
        endpoint: '/v1/likes/toggle',
        data: {'type': type, 'type_id': typeId},
        fromJson: (json) => LikeModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to toggle like',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get my likes
  Future<List<LikeModel>> getMyLikes() async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        endpoint: '/v1/user/likes',
        fromJson: (json) => (json as List)
            .map((item) => LikeModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data as List<LikeModel>;
      }

      throw ApiException(
        message: response.message ?? 'Failed to fetch likes',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }
}
