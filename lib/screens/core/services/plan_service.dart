import 'package:dio/dio.dart';
import '../constants/Api.dart';
import 'dio_client.dart';

class PlanService {
  final _dio = DioClient().dio;

  Future<Response> getPlans({String? search, int? userId}) async {
    return await _dio.get(Api.plans, queryParameters: {
      if (search != null) 'search': search,
      if (userId != null) 'user_id': userId,
    });
  }

  Future<Response> getMyPlans() async {
    return await _dio.get(Api.myPlans);
  }

  Future<Response> getPlan(int id) async {
    return await _dio.get(Api.planById(id));
  }

  Future<Response> createPlan({
    required String title,
    List<Map<String, dynamic>>? planItems,
  }) async {
    return await _dio.post(Api.plans, data: {
      'title': title,
      if (planItems != null) 'plan_items': planItems,
    });
  }

  Future<Response> updatePlan(int id, Map<String, dynamic> data) async {
    return await _dio.put(Api.planById(id), data: data);
  }

  Future<Response> deletePlan(int id) async {
    return await _dio.delete(Api.planById(id));
  }
}
