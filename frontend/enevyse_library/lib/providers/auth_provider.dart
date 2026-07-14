import 'package:flutter/material.dart';
import '../repository/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final success = await _authRepository.login(email, password);
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
    notifyListeners();
  }
}
