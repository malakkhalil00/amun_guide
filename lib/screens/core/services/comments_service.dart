import 'package:dio/dio.dart';
import '../constants/Api.dart';
import 'dio_client.dart';

class CommentsService {
  final _dio = DioClient().dio;

  Future<Response> getSubjectComments(String type, int id) async {
    return await _dio.get(Api.subjectComments(type, id));
  }

  Future<Response> getSubjectCommentsCount(String type, int id) async {
    return await _dio.get(Api.subjectCommentsCount(type, id));
  }

  Future<Response> getComment(int id) async {
    return await _dio.get(Api.commentById(id));
  }

  Future<Response> addComment({
    required String content,
    required String commentableType,
    required int commentableId,
  }) async {
    return await _dio.post(Api.comments, data: {
      'content': content,
      'commentable_type': commentableType,
      'commentable_id': commentableId,
    });
  }

  Future<Response> addSubjectComment({
    required String type,
    required int id,
    required String content,
  }) async {
    return await _dio.post(Api.subjectComments(type, id), data: {'content': content});
  }

  Future<Response> updateComment(int id, String content) async {
    return await _dio.put(Api.commentById(id), data: {'content': content});
  }

  Future<Response> deleteComment(int id) async {
    return await _dio.delete(Api.commentById(id));
  }

  Future<Response> getUserComments(int userId) async {
    return await _dio.get(Api.userComments(userId));
  }
}
