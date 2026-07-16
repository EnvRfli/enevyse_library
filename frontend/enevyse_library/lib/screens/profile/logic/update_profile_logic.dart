import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/auth_provider.dart';

class UpdateProfileLogic extends ChangeNotifier {
  final AuthProvider authProvider;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController memberIdController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  File? profileImage;
  bool isLoading = false;
  List<String> selectedCategories = [];

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

  UpdateProfileLogic(this.authProvider) {
    final user = authProvider.currentUser;
    nameController = TextEditingController(text: user?.name ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    memberIdController = TextEditingController(text: user?.memberId ?? '');
    phoneController = TextEditingController(text: user?.phone ?? '');
    addressController = TextEditingController(text: user?.address ?? '');

    if (user != null && user.preferredCategories.isNotEmpty) {
      selectedCategories = List.from(user.preferredCategories);
    }
  }

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<bool> saveProfile() async {
    if (!formKey.currentState!.validate()) return false;
    isLoading = true;
    notifyListeners();

    try {
      String? pictureUrl;
      if (profileImage != null) {
        pictureUrl = await authProvider.uploadProfilePicture(profileImage!);
        if (pictureUrl == null) {
          isLoading = false;
          notifyListeners();
          return false;
        }
      }

      final data = <String, dynamic>{
        'phone': phoneController.text,
        'address': addressController.text,
        'preferred_categories': selectedCategories,
      };

      if (pictureUrl != null) {
        data['profile_picture_url'] = pictureUrl;
      }

      final success = await authProvider.updateProfile(data);
      isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    memberIdController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
