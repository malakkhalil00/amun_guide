import 'package:dio/dio.dart';
import '../constants/Api.dart';
import 'dio_client.dart';

class AuthService {
  final _dio = DioClient().dio;

  /// Register a new user with form data (supports profile_image file)
  Future<Response> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    String? profileImagePath,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      if (profileImagePath != null)
        'profile_image':
            await MultipartFile.fromFile(profileImagePath, filename: 'profile.jpg'),
    });

    return await _dio.post(Api.register, data: formData);
  }

  /// Login with email & password, returns token
  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await _dio.post(
      Api.login,
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  /// Send forgot password email
  Future<Response> forgotPassword({required String email}) async {
    return await _dio.post(
      Api.forgotPassword,
      data: {'email': email},
    );
  }

  /// Reset password using token
  Future<Response> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await _dio.post(
      Api.resetPassword,
      queryParameters: {
        'token': token,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  /// Logout – clear local storage
  Future<void> logout() async {
    await DioClient.clearAll();
  }
}
