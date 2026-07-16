import 'package:flutter/material.dart';
import '../../../repository/book_repository.dart';
import '../../../models/book.dart';

class ManageBooksLogic extends ChangeNotifier {
  final BookRepository _bookRepository;
  final TextEditingController searchController = TextEditingController();

  List<Book> books = [];
  bool isLoading = false;

  ManageBooksLogic(this._bookRepository) {
    fetchBooks();
  }

  Future<void> fetchBooks({String? query}) async {
    isLoading = true;
    notifyListeners();

    try {
      final fetchedBooks = await _bookRepository.getAllBooks(title: query);
      books = fetchedBooks ?? [];
    } catch (e) {
      books = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onSearchChanged() {
    fetchBooks(query: searchController.text);
  }

  Future<bool> deleteBook(String id) async {
    final success = await _bookRepository.deleteBook(id);
    if (success) {
      await fetchBooks(query: searchController.text);
    }
    return success;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
