import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../providers/auth_provider.dart';

class RegisterLogic extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isFormValid = false;

  RegisterLogic() {
    nameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    Future.microtask(() {
      if (formKey.currentState == null || !formKey.currentState!.mounted) return;
      final valid = formKey.currentState!.validate();
      if (valid != isFormValid) {
        isFormValid = valid;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    nameController.removeListener(_validateForm);
    emailController.removeListener(_validateForm);
    passwordController.removeListener(_validateForm);
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleRegister(BuildContext context) async {
    if (formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        nameController.text.trim(),
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
