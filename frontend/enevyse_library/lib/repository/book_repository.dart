import 'dart:convert';
import 'dart:io';
import '../core/network/api_client.dart';
import '../models/book.dart';

class BookRepository {
  final ApiClient _apiClient = ApiClient();

  Future<String?> createBook(Map<String, dynamic> bookData) async {
    try {
      // Assuming bookData maps directly to the required JSON structure
      final response = await _apiClient.post(
        Microservice.book,
        '/api/v1/books',
        body: bookData,
        requiresAuth: true, // Needs admin token
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id']; // ID of the newly created book
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateBook(String id, Map<String, dynamic> bookData) async {
    try {
      final response = await _apiClient.put(
        Microservice.book,
        '/api/v1/books/$id',
        body: bookData,
        requiresAuth: true,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Book>?> getAllBooks({String? title, String? category, String? language, double? minRating}) async {
    try {
      final queryParams = <String, String>{};
      if (title != null && title.isNotEmpty) queryParams['title'] = title;
      if (category != null && category.isNotEmpty && category != 'All') queryParams['category'] = category;
      if (language != null && language.isNotEmpty) queryParams['language'] = language;
      if (minRating != null) queryParams['min_rating'] = minRating.toString();

      final uri = Uri(path: '/api/v1/books', queryParameters: queryParams.isNotEmpty ? queryParams : null);
      
      final response = await _apiClient.get(
        Microservice.book,
        uri.toString(),
        requiresAuth: false,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Book.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Book?> getBook(String id) async {
    try {
      final response = await _apiClient.get(
        Microservice.book,
        '/api/v1/books/$id',
        requiresAuth: false,
      );
      if (response.statusCode == 200) {
        return Book.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> uploadCover(String bookId, File image) async {
    try {
      final response = await _apiClient.postMultipart(
        Microservice.book,
        '/api/v1/books/$bookId/cover',
        fileField: 'cover_image',
        filePath: image.path,
        requiresAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
