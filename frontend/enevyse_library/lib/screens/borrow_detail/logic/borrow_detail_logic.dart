import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../models/mock_transaction.dart';

class BorrowDetailLogic extends ChangeNotifier {
  final String transactionId;
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  MockTransaction? _transaction;
  MockTransaction? get transaction => _transaction;

  BorrowDetailLogic({required this.transactionId}) {
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(Microservice.transaction, '/api/v1/transactions/$transactionId');

      if (response.statusCode == 200) {
        // Parse actual data here
        _applyMockData();
      } else {
        _applyMockData();
      }
    } catch (e) {
      _applyMockData();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _applyMockData() {
    final allMocks = [...mockTransactions, ...mockHistoryTransactions];
    try {
      _transaction = allMocks.firstWhere((t) => t.id == transactionId);
    } catch (e) {
      // Not found in mocks
      _transaction = allMocks.first; // Fallback so UI doesn't break
    }
  }
}
