import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../repository/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();

  List<Transaction> myTransactions = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchMyTransactions() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      myTransactions = await _repository.getMyTransactions();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<Transaction?> getTransaction(String id) async {
    try {
      return await _repository.getTransactionById(id);
    } catch (e) {
      return null;
    }
  }

  Future<Transaction?> borrowBook(String bookId, String pickupLocation) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final transaction = await _repository.borrowBook(bookId, pickupLocation);
      if (transaction != null) {
        // Optionally insert it at the beginning of the list
        myTransactions.insert(0, transaction);
        isLoading = false;
        notifyListeners();
        return transaction;
      } else {
        errorMessage = 'Failed to borrow book';
      }
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
    return null;
  }
}
