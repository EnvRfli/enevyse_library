import 'dart:convert';
import '../core/network/api_client.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Transaction?> borrowBook(String bookId, String pickupLocation) async {
    try {
      final response = await _apiClient.post(
        Microservice.transaction,
        '/api/v1/transactions/borrow',
        body: {
          'book_id': bookId,
          'pickup_location': pickupLocation,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          if (data.containsKey('transaction')) {
            return Transaction.fromJson(data['transaction']);
          } else if (data.containsKey('data')) {
            return Transaction.fromJson(data['data']);
          } else {
            return Transaction.fromJson(data);
          }
        }
      }
      return null;
    } catch (e) {
      print('Error in borrowBook: $e');
      return null;
    }
  }

  Future<List<Transaction>> getMyTransactions() async {
    try {
      final response = await _apiClient.get(
        Microservice.transaction,
        '/api/v1/transactions/me',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((item) => Transaction.fromJson(item)).toList();
        } else if (data is Map && data['data'] is List) {
          return (data['data'] as List)
              .map((item) => Transaction.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error in getMyTransactions: $e');
      return [];
    }
  }

  Future<Transaction?> getTransactionById(String id) async {
    try {
      final response = await _apiClient.get(
        Microservice.transaction,
        '/api/v1/transactions/$id',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            return Transaction.fromJson(data['data']);
          } else {
            return Transaction.fromJson(data);
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
