import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  Future<UserModel> register(String name, String email, String password) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.registerEndpoint,
        data: {
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

      await StorageService.saveToken(token);
      await StorageService.saveUser(user);

      return user;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Registration failed: $e');
    }
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.loginEndpoint,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

      await StorageService.saveToken(token);
      await StorageService.saveUser(user);

      return user;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Login failed: $e');
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await _client.dio.get(ApiConstants.meEndpoint);
      final data = response.data['data'] as Map<String, dynamic>;
      final user = UserModel.fromJson(data);

      await StorageService.saveUser(user);
      return user;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to retrieve profile: $e');
    }
  }

  Future<void> logout() async {
    await StorageService.clearAuth();
  }
}
