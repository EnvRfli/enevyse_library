import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/network/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        Microservice.identity,
        '/api/v1/auth/login',
        body: {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token != null) {
          await _secureStorage.write(key: 'jwt_token', value: token);
          return true;
        }
      } else if (response.statusCode == 401) {
        throw Exception('invalid_credentials');
      } else {
        throw Exception('error_occurred');
      }
    } catch (e) {
      if (e.toString().contains('invalid_credentials')) {
        rethrow;
      }
      throw Exception('error_occurred');
    }
    return false;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'jwt_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'jwt_token');
    return token != null && token.isNotEmpty;
  }
}
