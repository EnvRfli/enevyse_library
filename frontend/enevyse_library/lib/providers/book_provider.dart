import 'dart:async';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../repository/book_repository.dart';

class BookProvider extends ChangeNotifier {
  final BookRepository _bookRepository;

  BookProvider(this._bookRepository);

  // State for Explore/List
  List<Book> books = [];
  bool isLoadingBooks = false;
  String? booksErrorMessage;

  String searchQuery = '';
  String selectedCategory = 'All';
  double? selectedMinRating;
  String selectedSortBy = 'created_at_desc';

  bool _isCategoriesLoaded = false;
  List<String> categories = ['All'];

  Timer? _debounce;

  // State for Book Detail
  Book? selectedBook;
  bool isLoadingBookDetail = false;
  String? bookDetailErrorMessage;

  // State for Home Screen
  List<Book> recommendedBooks = [];
  List<Book> newArrivalBooks = [];
  bool isLoadingHome = false;

  // --- Methods for Explore/List ---

  void onSearchChanged(String query) {
    searchQuery = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchBooks();
    });
  }

  void onCategorySelected(String category) {
    if (selectedCategory == category) return;
    selectedCategory = category;
    fetchBooks();
  }

  void onMinRatingSelected(double? rating) {
    if (selectedMinRating == rating) return;
    selectedMinRating = rating;
    fetchBooks();
  }

  void onSortBySelected(String sortBy) {
    if (selectedSortBy == sortBy) return;
    selectedSortBy = sortBy;
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    isLoadingBooks = true;
    booksErrorMessage = null;
    notifyListeners();

    try {
      final fetchedBooks = await _bookRepository.getAllBooks(
        title: searchQuery.isEmpty ? null : searchQuery,
        category: selectedCategory == 'All' ? null : selectedCategory,
        minRating: selectedMinRating,
        sortBy: selectedSortBy,
      );
      if (fetchedBooks != null) {
        books = fetchedBooks;

        if (!_isCategoriesLoaded &&
            selectedCategory == 'All' &&
            searchQuery.isEmpty) {
          final Set<String> uniqueCats = {'All'};
          for (var b in books) {
            uniqueCats.addAll(b.categories);
          }
          categories = uniqueCats.toList();
          _isCategoriesLoaded = true;
        }
      } else {
        booksErrorMessage = 'Failed to load books';
      }
    } catch (e) {
      booksErrorMessage = 'Error: $e';
    } finally {
      isLoadingBooks = false;
      notifyListeners();
    }
  }

  // --- Methods for Home Screen ---

  Future<void> fetchHomeBooks(List<String> preferredCategories) async {
    isLoadingHome = true;
    notifyListeners();

    try {
      // 1. Fetch New Arrivals
      final newArrivals = await _bookRepository.getAllBooks(sortBy: 'created_at_desc');
      if (newArrivals != null) {
        newArrivalBooks = newArrivals.take(10).toList();
      }

      // 2. Fetch Recommended
      // If user has preferred categories, fetch by the first one (as an example, or fetch all and filter).
      // If not, fetch by available_copies_asc
      if (preferredCategories.isNotEmpty) {
        // Just using the first preferred category for the query, 
        // ideally backend supports multiple categories in filter.
        final recommended = await _bookRepository.getAllBooks(category: preferredCategories.first);
        if (recommended != null) {
          recommendedBooks = recommended.take(10).toList();
        }
      } else {
        final recommended = await _bookRepository.getAllBooks(sortBy: 'available_copies_asc');
        if (recommended != null) {
          recommendedBooks = recommended.take(10).toList();
        }
      }
    } catch (e) {
      // Handle error if needed
    } finally {
      isLoadingHome = false;
      notifyListeners();
    }
  }

  // --- Methods for Book Detail ---

  Future<void> fetchBookDetails(String id) async {
    isLoadingBookDetail = true;
    bookDetailErrorMessage = null;
    selectedBook = null;
    notifyListeners();

    try {
      final fetchedBook = await _bookRepository.getBook(id);
      if (fetchedBook != null) {
        selectedBook = fetchedBook;
      } else {
        bookDetailErrorMessage = 'Book not found';
      }
    } catch (e) {
      bookDetailErrorMessage = 'Error loading book details: $e';
    } finally {
      isLoadingBookDetail = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
