import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../models/mock_transaction.dart';

class HistoryLogic extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool _isCurrentTab = true; // true = Current, false = History
  bool get isCurrentTab => _isCurrentTab;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<MockTransaction> _currentTransactions = [];
  List<MockTransaction> get currentTransactions => _currentTransactions;

  List<MockTransaction> _historyTransactions = [];
  List<MockTransaction> get historyTransactions => _historyTransactions;

  HistoryLogic() {
    fetchTransactions();
  }

  void setTab(bool isCurrent) {
    if (_isCurrentTab != isCurrent) {
      _isCurrentTab = isCurrent;
      notifyListeners();
    }
  }

  Future<void> fetchTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(Microservice.transaction, '/api/v1/transactions/me');

      if (response.statusCode == 200) {
        // In a real scenario, we parse json here.
        // For now, if it succeeds or even if it fails, we will fallback to mock data
        // just to ensure the UI is visible.
        _applyMockData();
      } else {
        // Fallback to mock data on error so UI can still be reviewed
        _applyMockData();
      }
    } catch (e) {
      // Fallback on connection error
      _applyMockData();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _applyMockData() {
    _currentTransactions = mockTransactions;
    _historyTransactions = mockHistoryTransactions;
  }
}
