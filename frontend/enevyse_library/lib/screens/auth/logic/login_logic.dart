import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../providers/auth_provider.dart';
import '../../../repository/auth_repository.dart';

class LoginLogic extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isFormValid = false;

  LoginLogic() {
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    _loadLastCredentials();
  }

  Future<void> _loadLastCredentials() async {
    final repo = AuthRepository();
    final lastEmail = await repo.getLastEmail();
    final lastPassword = await repo.getLastPassword();
    if (lastEmail != null) {
      emailController.text = lastEmail;
    }
    if (lastPassword != null) {
      passwordController.text = lastPassword;
    }
    _validateForm();
  }

  void _validateForm() {
    Future.microtask(() {
      if (formKey.currentState == null || !formKey.currentState!.mounted) {
        return;
      }
      final valid = formKey.currentState!.validate();
      if (valid != isFormValid) {
        isFormValid = valid;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    emailController.removeListener(_validateForm);
    passwordController.removeListener(_validateForm);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (success) {
        if (context.mounted) context.go('/home');
      } else {
        if (context.mounted && authProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage!.tr()),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              margin: EdgeInsets.all(16.w),
            ),
          );
          authProvider.clearError();
        }
      }
    }
  }
}
