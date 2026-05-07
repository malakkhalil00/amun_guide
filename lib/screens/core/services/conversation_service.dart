import 'package:dio/dio.dart';
import '../constants/Api.dart';
import 'dio_client.dart';

class ConversationService {
  final _dio = DioClient().dio;

  Future<Response> createConversation({String? context}) async {
    return await _dio.post(Api.conversations, data: {
      if (context != null) 'context': context,
    });
  }

  Future<Response> getMyConversations() async {
    return await _dio.get(Api.conversations);
  }

  Future<Response> getConversation(int id) async {
    return await _dio.get(Api.conversationById(id));
  }

  Future<Response> deleteConversation(int id) async {
    return await _dio.delete(Api.conversationById(id));
  }

  Future<Response> sendMessage(int conversationId, Map<String, dynamic> data) async {
    return await _dio.post(Api.conversationMessages(conversationId), data: data);
  }

  Future<Response> getMessages(int conversationId) async {
    return await _dio.get(Api.conversationMessages(conversationId));
  }

  Future<Response> getImages(int conversationId) async {
    return await _dio.get(Api.conversationImages(conversationId));
  }

  Future<Response> getStatistics() async {
    return await _dio.get(Api.conversationStatistics);
  }
}
