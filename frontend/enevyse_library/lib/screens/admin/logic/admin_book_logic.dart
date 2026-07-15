import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../repository/book_repository.dart';

class AdminBookLogic extends ChangeNotifier {
  final BookRepository _bookRepository = BookRepository();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController publisherController = TextEditingController();
  final TextEditingController totalCopiesController =
      TextEditingController(text: '1');
  final TextEditingController totalPagesController =
      TextEditingController();
  final TextEditingController synopsisController = TextEditingController();

  DateTime? publishedDate;
  File? coverImage;
  bool isLoading = false;

  // New Fields for dropdown/chips
  List<String> selectedCategories = [];
  List<String> selectedGenres = [];
  String? selectedLanguage;

  static const List<String> availableCategories = [
    'Programming',
    'Technology',
    'Fantasy',
    'Novel',
    'Business',
    'Self-Help',
    'History',
    'Biography'
  ];
  static const List<String> availableGenres = [
    'Science Fiction',
    'Fantasy',
    'Mystery',
    'Thriller',
    'Romance',
    'Horror',
    'Adventure',
    'Historical',
    'Drama',
    'Comedy',
    'Detective',
    'Mythology',
    'Dystopian',
    'Magical Realism',
    'Gothic'
  ];
  static const List<String> availableLanguages = [
    'English',
    'Indonesian',
    'Spanish',
    'Japanese',
    'Korean',
    'Mandarin'
  ];

  bool get isNovelSelected => selectedCategories.contains('Novel');

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
      if (category == 'Novel') {
        selectedGenres.clear(); // Reset genres if Novel is deselected
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

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      coverImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<bool> addBook(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    if (publishedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a published date')),
      );
      return false;
    }

    if (selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a language')),
      );
      return false;
    }

    if (selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category')),
      );
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      final bookData = {
        'title': titleController.text.trim(),
        'author': authorController.text.trim(),
        'publisher': publisherController.text.trim(),
        'published': publishedDate!.toUtc().toIso8601String(),
        'categories': selectedCategories,
        'genres': selectedGenres.isEmpty ? null : selectedGenres,
        'language': selectedLanguage,
        'total_copies': int.tryParse(totalCopiesController.text.trim()) ?? 1,
        'total_pages': int.tryParse(totalPagesController.text.trim()) ?? 0,
        'synopsis': synopsisController.text.trim(),
        // Backend handles default available_copies and ratings
      };

      final bookId = await _bookRepository.createBook(bookData);

      if (bookId != null) {
        if (coverImage != null) {
          final coverSuccess =
              await _bookRepository.uploadCover(bookId, coverImage!);
          if (!coverSuccess) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Book created, but cover upload failed.')),
              );
            }
          }
        }

        isLoading = false;
        notifyListeners();
        return true;
      }

      isLoading = false;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create book')),
        );
      }
      return false;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An error occurred while creating the book')),
        );
      }
      return false;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    publisherController.dispose();
    totalCopiesController.dispose();
    totalPagesController.dispose();
    synopsisController.dispose();
    super.dispose();
  }
}
