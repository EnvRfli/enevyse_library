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
  bool isFetchingMore = false;
  bool hasMoreExploreBooks = true;
  int currentExplorePage = 1;
  final int exploreLimit = 10;
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

  // State for Favorites
  List<Book> favoriteBooks = [];
  Set<String> favoriteBookIds = {};
  bool isLoadingFavorites = false;

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
    fetchBooks(isRefresh: true);
  }

  void onMinRatingSelected(double? rating) {
    if (selectedMinRating == rating) return;
    selectedMinRating = rating;
    fetchBooks(isRefresh: true);
  }

  void onSortBySelected(String sortBy) {
    if (selectedSortBy == sortBy) return;
    selectedSortBy = sortBy;
    fetchBooks(isRefresh: true);
  }

  Future<void> fetchBooks({bool isRefresh = true}) async {
    if (isRefresh) {
      currentExplorePage = 1;
      hasMoreExploreBooks = true;
      isLoadingBooks = true;
      books.clear();
    } else {
      if (!hasMoreExploreBooks || isFetchingMore) return;
      isFetchingMore = true;
      currentExplorePage++;
    }
    
    booksErrorMessage = null;
    notifyListeners();

    try {
      final fetchedBooks = await _bookRepository.getAllBooks(
        title: searchQuery.isEmpty ? null : searchQuery,
        category: selectedCategory == 'All' ? null : selectedCategory,
        minRating: selectedMinRating,
        sortBy: selectedSortBy,
        page: currentExplorePage,
        limit: exploreLimit,
      );
      if (fetchedBooks != null) {
        if (fetchedBooks.length < exploreLimit) {
          hasMoreExploreBooks = false;
        }

        if (isRefresh) {
          books = fetchedBooks;
        } else {
          books.addAll(fetchedBooks);
        }

        if (!_isCategoriesLoaded &&
            selectedCategory == 'All' &&
            searchQuery.isEmpty &&
            isRefresh) {
          // Note: Full categories might not be available if paginated, 
          // usually categories are fetched from a separate endpoint, but keeping this for now.
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
      isFetchingMore = false;
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
      // We fetch a larger batch of books and then sort locally so that 
      // books matching the user's preferred categories appear at the top.
      final allBooksForRecommendation = await _bookRepository.getAllBooks(
        sortBy: 'rating_desc', 
        limit: 50,
      );
      
      if (allBooksForRecommendation != null) {
        if (preferredCategories.isNotEmpty) {
          // Normalize preferred categories for case-insensitive comparison
          final lowerPrefCats = preferredCategories.map((c) => c.toLowerCase()).toSet();
          
          allBooksForRecommendation.sort((a, b) {
            final aMatches = a.categories.any((c) => lowerPrefCats.contains(c.toLowerCase()));
            final bMatches = b.categories.any((c) => lowerPrefCats.contains(c.toLowerCase()));
            
            if (aMatches && !bMatches) return -1;
            if (!aMatches && bMatches) return 1;
            return 0; // maintain original order (rating_desc) for ties
          });
        }
        
        recommendedBooks = allBooksForRecommendation.take(10).toList();
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

  // --- Methods for Favorites ---

  Future<void> fetchFavorites() async {
    isLoadingFavorites = true;
    notifyListeners();
    try {
      final fetchedFavorites = await _bookRepository.getFavorites();
      if (fetchedFavorites != null) {
        favoriteBooks = fetchedFavorites;
        favoriteBookIds = fetchedFavorites.map((b) => b.id).toSet();
      }
    } catch (e) {
      // Handle error if needed
    } finally {
      isLoadingFavorites = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String bookId) async {
    final isCurrentlyFavorite = favoriteBookIds.contains(bookId);
    
    // Optimistic UI update
    if (isCurrentlyFavorite) {
      favoriteBookIds.remove(bookId);
      favoriteBooks.removeWhere((b) => b.id == bookId);
    } else {
      favoriteBookIds.add(bookId);
      if (selectedBook != null && selectedBook!.id == bookId) {
        favoriteBooks.add(selectedBook!);
      }
    }
    notifyListeners();

    try {
      final isFavoriteNow = await _bookRepository.toggleFavorite(bookId);
      if (isFavoriteNow != !isCurrentlyFavorite) {
        fetchFavorites(); // Resync if optimistic update was wrong
      }
    } catch (e) {
      fetchFavorites(); // Resync on error
    }
  }

  /// Clears all cached book data (called on logout)
  void clearState() {
    books = [];
    recommendedBooks = [];
    newArrivalBooks = [];
    favoriteBooks = [];
    favoriteBookIds = {};
    selectedBook = null;
    booksErrorMessage = null;
    bookDetailErrorMessage = null;
    searchQuery = '';
    selectedCategory = 'All';
    selectedMinRating = null;
    selectedSortBy = 'created_at_desc';
    currentExplorePage = 1;
    hasMoreExploreBooks = true;
    _isCategoriesLoaded = false;
    categories = ['All'];
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
