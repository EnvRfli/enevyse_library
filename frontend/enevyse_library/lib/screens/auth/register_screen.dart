import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/register_logic.dart';
import 'widgets/register_form.dart';
import 'widgets/login_header.dart'; // We can reuse the header style
import '../../theme/app_colors.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterLogic(),
      child: const _RegisterScreenView(),
    );
  }
}

class _RegisterScreenView extends StatelessWidget {
  const _RegisterScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: const [
            LoginHeader(), // Using the same header style
            RegisterForm(),
          ],
        ),
      ),
    );
  }
}
