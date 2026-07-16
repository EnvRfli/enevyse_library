import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../repository/book_repository.dart';
import '../../../models/book.dart';

class EditBookLogic extends ChangeNotifier {
  final BookRepository _bookRepository;

  EditBookLogic(this._bookRepository);

  final TextEditingController idController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController publisherController = TextEditingController();
  final TextEditingController synopsisController = TextEditingController();
  final TextEditingController pagesController = TextEditingController();
  final TextEditingController totalCopiesController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  File? coverImage;
  String? currentCoverUrl;
  Book? _loadedBook;

  DateTime? publishedDate;
  List<String> selectedCategories = [];
  List<String> selectedGenres = [];
  String? selectedLanguage;

  static const List<String> availableCategories = [
    'Programming', 'Technology', 'Fantasy', 'Novel', 'Business', 'Self-Help', 'History', 'Biography'
  ];
  static const List<String> availableGenres = [
    'Science Fiction', 'Fantasy', 'Mystery', 'Thriller', 'Romance', 'Horror',
    'Adventure', 'Historical', 'Drama', 'Comedy', 'Detective', 'Mythology',
    'Dystopian', 'Magical Realism', 'Gothic'
  ];
  static const List<String> availableLanguages = [
    'English', 'Indonesian', 'Spanish', 'Japanese', 'Korean', 'Mandarin'
  ];

  bool get isNovelSelected => selectedCategories.contains('Novel');

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
      if (category == 'Novel') {
        selectedGenres.clear();
      }
    } else {
      selectedCategories.add(category);
    }
    notifyListeners();
  }

  void toggleGenre(String genre) {
    if (selectedGenres.contains(genre)) {
      selectedGenres.remove(genre);
    } else {
      selectedGenres.add(genre);
    }
    notifyListeners();
  }

  void setLanguage(String? language) {
    selectedLanguage = language;
    notifyListeners();
  }

  void setPublishedDate(DateTime date) {
    publishedDate = date;
    notifyListeners();
  }

  bool get hasLoadedBook => titleController.text.isNotEmpty;

  Future<void> fetchBook(String id) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    coverImage = null;
    currentCoverUrl = null;
    notifyListeners();

    try {
      final book = await _bookRepository.getBook(id);
      if (book != null) {
        _loadedBook = book;
        titleController.text = book.title;
        authorController.text = book.author;
        publisherController.text = book.publisher;
        synopsisController.text = book.synopsis;
        pagesController.text = book.totalPages.toString();
        totalCopiesController.text = book.totalCopies.toString();
        currentCoverUrl = book.coverUrl;
        
        publishedDate = book.published;
        selectedCategories = List.from(book.categories);
        selectedGenres = List.from(book.genres);
        selectedLanguage = book.language;

        successMessage = 'Book loaded successfully';
      } else {
        errorMessage = 'Book not found';
      }
    } catch (e) {
      errorMessage = 'Failed to fetch book: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      coverImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<bool> updateBook() async {
    if (idController.text.isEmpty) {
      errorMessage = 'Book ID is required';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final bookData = {
        'title': titleController.text,
        'author': authorController.text,
        'publisher': publisherController.text,
        'synopsis': synopsisController.text,
        'total_pages': int.tryParse(pagesController.text) ?? 0,
        'total_copies': int.tryParse(totalCopiesController.text) ?? 1,
        'available_copies': _loadedBook?.availableCopies ?? 1,
        'published': publishedDate?.toIso8601String() ?? _loadedBook?.published?.toIso8601String(),
        'categories': selectedCategories,
        'genres': selectedGenres,
        'language': selectedLanguage ?? _loadedBook?.language ?? '',
        'cover_url': _loadedBook?.coverUrl,
        'created_at': _loadedBook?.createdAt?.toIso8601String(),
      };

      final success = await _bookRepository.updateBook(idController.text, bookData);
      if (success) {
        if (coverImage != null) {
          final coverSuccess = await _bookRepository.uploadCover(idController.text, coverImage!);
          if (!coverSuccess) {
            errorMessage = 'Book updated, but cover upload failed';
            return false; // Wait, actually it succeeded partially, but we return true in UI to pop?
            // I'll just set successMessage anyway but alert if cover failed.
            // Let's just return true and UI can handle it.
          }
        }
        successMessage = 'Book updated successfully!';
        return true;
      } else {
        errorMessage = 'Failed to update book';
        return false;
      }
    } catch (e) {
      errorMessage = 'Error updating book: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
