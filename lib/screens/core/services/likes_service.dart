import 'package:dio/dio.dart';
import '../constants/Api.dart';
import 'dio_client.dart';

class LikesService {
  final _dio = DioClient().dio;

  Future<Response> getSubjectLikes(String type, int id) async {
    return await _dio.get(Api.subjectLikes(type, id));
  }

  Future<Response> getSubjectLikesCount(String type, int id) async {
    return await _dio.get(Api.subjectLikesCount(type, id));
  }

  Future<Response> addLike({required String likeableType, required int likeableId}) async {
    return await _dio.post(Api.likes, data: {
      'likeable_type': likeableType,
      'likeable_id': likeableId,
    });
  }

  Future<Response> toggleLike({required String likeableType, required int likeableId}) async {
    return await _dio.post(Api.likesToggle, data: {
      'likeable_type': likeableType,
      'likeable_id': likeableId,
    });
  }

  Future<Response> removeLike(int id) async {
    return await _dio.delete(Api.likeById(id));
  }

  Future<Response> removeSubjectLike(String type, int id) async {
    return await _dio.delete(Api.subjectLikes(type, id));
  }

  Future<Response> getUserLikes() async {
    return await _dio.get(Api.userLikes);
  }
}
