import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../repository/transaction_repository.dart';
import '../repository/book_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();
  final BookRepository _bookRepository = BookRepository();

  List<Transaction> myTransactions = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchMyTransactions() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final transactions = await _repository.getMyTransactions();
      
      // Fetch book details for each transaction
      final List<Transaction> populatedTransactions = [];
      for (var tx in transactions) {
        if (tx.bookId.isNotEmpty && tx.book == null) {
          final book = await _bookRepository.getBook(tx.bookId);
          populatedTransactions.add(tx.copyWith(book: book));
        } else {
          populatedTransactions.add(tx);
        }
      }

      myTransactions = populatedTransactions;
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<Transaction?> getTransaction(String id) async {
    try {
      final tx = await _repository.getTransactionById(id);
      if (tx != null && tx.bookId.isNotEmpty && tx.book == null) {
        final book = await _bookRepository.getBook(tx.bookId);
        return tx.copyWith(book: book);
      }
      return tx;
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
        // Fetch book details to populate the transaction before inserting
        Transaction txToInsert = transaction;
        if (txToInsert.bookId.isNotEmpty && txToInsert.book == null) {
          final book = await _bookRepository.getBook(txToInsert.bookId);
          txToInsert = txToInsert.copyWith(book: book);
        }

        // Optionally insert it at the beginning of the list
        myTransactions.insert(0, txToInsert);
        isLoading = false;
        notifyListeners();
        return txToInsert;
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
