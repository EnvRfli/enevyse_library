import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/network/api_client.dart';

class BorrowLogic extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  String _pickupLocation = 'Main Library — Front Desk';
  String get pickupLocation => _pickupLocation;

  String _purpose = '';
  String get purpose => _purpose;

  bool _agreedToTerms = false;
  bool get agreedToTerms => _agreedToTerms;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<String> pickupLocations = [
    'Main Library — Front Desk',
    'North Wing — Lockers',
    'South Branch',
  ];

  void setPickupLocation(String? value) {
    if (value != null) {
      _pickupLocation = value;
      notifyListeners();
    }
  }

  void setPurpose(String value) {
    _purpose = value;
    notifyListeners();
  }

  void setAgreedToTerms(bool? value) {
    if (value != null) {
      _agreedToTerms = value;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<String?> submitBorrowRequest(String bookId) async {
    if (!_agreedToTerms) {
      _errorMessage = 'error_agree_terms'.tr();
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        Microservice.transaction,
        '/api/v1/transactions/borrow',
        body: {
          'book_id': bookId,
          'pickup_location': _pickupLocation,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _isLoading = false;
        notifyListeners();
        // Return ID if exists, otherwise generate a mock one for presentation
        return data['data']?['id'] ?? data['id'] ?? 'LB-20260714-118';
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        _errorMessage = data['message'] ?? 'error_limit_exceeded'.tr();
      } else {
        _errorMessage = 'error_unknown'.tr();
      }
    } catch (e) {
      _errorMessage = 'error_connection'.tr();
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }
}
