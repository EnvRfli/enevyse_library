import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';

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
        final userName = data['user']?['name'];
        if (token != null) {
          await _secureStorage.write(key: 'jwt_token', value: token);
          if (userName != null) {
            await _secureStorage.write(key: 'user_name', value: userName);
          }
          await _secureStorage.write(key: 'last_email', value: email);
          await _secureStorage.write(key: 'last_password', value: password);
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

  Future<String?> getLastEmail() async {
    return await _secureStorage.read(key: 'last_email');
  }

  Future<String?> getLastPassword() async {
    return await _secureStorage.read(key: 'last_password');
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'jwt_token');
    await _secureStorage.delete(key: 'user_name');
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await _apiClient.post(
        Microservice.identity,
        '/api/v1/auth/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token != null) {
          await _secureStorage.write(key: 'jwt_token', value: token);
          return true;
        }
      } else if (response.statusCode == 409) {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'email_already_registered');
      }
      throw Exception('register_failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getMe() async {
    try {
      final response = await _apiClient.get(
        Microservice.identity,
        '/api/v1/me',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserName() async {
    return await _secureStorage.read(key: 'user_name');
  }

  Future<UserModel?> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        Microservice.identity,
        '/api/v1/me',
        body: data,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        return UserModel.fromJson(resData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadProfilePicture(File image) async {
    try {
      final response = await _apiClient.postMultipart(
        Microservice.identity,
        '/api/v1/me/profile-picture',
        fileField: 'profile_picture',
        filePath: image.path,
        requiresAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        return data[
            'cover_url']; // Reusing the same response key name or 'profile_picture_url' depending on backend
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'jwt_token');
    return token != null && token.isNotEmpty;
  }
}
