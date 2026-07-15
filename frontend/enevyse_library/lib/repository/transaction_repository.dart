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
        if (data['transaction'] != null) {
          return Transaction.fromJson(data['transaction']);
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
        if (data['data'] is List) {
          return (data['data'] as List)
              .map((item) => Transaction.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
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
        if (data['data'] != null) {
          return Transaction.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
