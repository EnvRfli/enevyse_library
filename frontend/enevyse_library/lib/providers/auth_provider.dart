import 'dart:io';
import 'package:flutter/material.dart';
import '../repository/auth_repository.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    if (isLoggedIn) {
      _currentUser = await _authRepository.getMe();
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final success = await _authRepository.register(name, email, password);
      if (success) {
        _currentUser = await _authRepository.getMe();
      } else {
        _errorMessage = 'register_failed';
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setLoading(false);
      final errorMsg = e.toString();
      if (errorMsg.contains('email already registered')) {
        _errorMessage = 'email_already_registered';
      } else {
        _errorMessage = 'error_occurred';
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final success = await _authRepository.login(email, password);
      if (success) {
        _currentUser = await _authRepository.getMe();
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setLoading(false);
      if (e.toString().contains('invalid_credentials')) {
        _errorMessage = 'invalid_credentials';
      } else {
        _errorMessage = 'error_occurred';
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _currentUser = null;
    notifyListeners();
  }


  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final updatedUser = await _authRepository.updateProfile(data);
      if (updatedUser != null) {
        _currentUser = updatedUser;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'update_profile_failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'error_occurred';
      notifyListeners();
      return false;
    }
  }

  Future<String?> uploadProfilePicture(File image) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final url = await _authRepository.uploadProfilePicture(image);
      _setLoading(false);
      if (url == null) {
        _errorMessage = 'upload_failed';
      }
      return url;
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'error_occurred';
      notifyListeners();
      return null;
    }
  }
}
