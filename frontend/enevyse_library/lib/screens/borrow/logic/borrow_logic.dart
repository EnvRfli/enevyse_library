import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';

class BorrowLogic extends ChangeNotifier {
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

  Future<String?> submitBorrowRequest(
      String bookId, BuildContext context) async {
    if (!_agreedToTerms) {
      _errorMessage = 'error_agree_terms'.tr();
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);
      final transaction =
          await transactionProvider.borrowBook(bookId, _pickupLocation);

      if (transaction != null) {
        _isLoading = false;
        notifyListeners();
        return transaction.id;
      } else {
        _errorMessage =
            transactionProvider.errorMessage ?? 'error_unknown'.tr();
      }
    } catch (e) {
      _errorMessage = 'error_connection'.tr();
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }
}
