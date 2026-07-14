import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum Microservice {
  identity,
  book,
  transaction,
}

class ApiClient {
  static const String _localhost =
      'http://192.168.1.9'; // Diubah untuk Emulator Mumu Player

  static const String identityBaseUrl = '$_localhost:3001';
  static const String bookBaseUrl = '$_localhost:8002';
  static const String transactionBaseUrl = '$_localhost:8003';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String _getBaseUrl(Microservice service) {
    switch (service) {
      case Microservice.identity:
        return identityBaseUrl;
      case Microservice.book:
        return bookBaseUrl;
      case Microservice.transaction:
        return transactionBaseUrl;
    }
  }

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<http.Response> get(Microservice service, String endpoint,
      {bool requiresAuth = true}) async {
    final baseUrl = _getBaseUrl(service);
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);

    return await http.get(url, headers: headers);
  }

  Future<http.Response> post(Microservice service, String endpoint,
      {required Map<String, dynamic> body, bool requiresAuth = true}) async {
    final baseUrl = _getBaseUrl(service);
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(Microservice service, String endpoint,
      {required Map<String, dynamic> body, bool requiresAuth = true}) async {
    final baseUrl = _getBaseUrl(service);
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);

    return await http.put(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(Microservice service, String endpoint,
      {bool requiresAuth = true}) async {
    final baseUrl = _getBaseUrl(service);
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);

    return await http.delete(url, headers: headers);
  }
}
