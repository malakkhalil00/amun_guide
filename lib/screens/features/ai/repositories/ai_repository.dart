import 'package:amin_gide/core/services/api_service.dart';
import 'package:amin_gide/features/ai/models/ai_models.dart';

/// AI Repository
class AIRepository {
  final ApiService _apiService;

  AIRepository(this._apiService);

  /// Create conversation
  Future<ConversationModel> createConversation() async {
    try {
      final response = await _apiService.post<ConversationModel>(
        endpoint: '/v1/conversations',
        data: {},
        fromJson: (json) => ConversationModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to create conversation',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Send message
  Future<MessageModel> sendMessage(int conversationId, String message) async {
    try {
      final response = await _apiService.post<MessageModel>(
        endpoint: '/v1/conversations/$conversationId/messages',
        data: {'content': message},
        fromJson: (json) => MessageModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to send message',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get conversation
  Future<ConversationModel> getConversation(int id) async {
    try {
      final response = await _apiService.get<ConversationModel>(
        endpoint: '/v1/conversations/$id',
        fromJson: (json) => ConversationModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to fetch conversation',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get my conversations
  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        endpoint: '/v1/conversations',
        fromJson: (json) => (json as List)
            .map((item) =>
                ConversationModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data as List<ConversationModel>;
      }

      throw ApiException(
        message: response.message ?? 'Failed to fetch conversations',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create plan from conversation
  Future<PlanModel> createPlan(int conversationId) async {
    try {
      final response = await _apiService.post<PlanModel>(
        endpoint: '/v1/conversations/$conversationId/create-plan',
        data: {},
        fromJson: (json) => PlanModel.fromJson(json),
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to create plan',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }
}
