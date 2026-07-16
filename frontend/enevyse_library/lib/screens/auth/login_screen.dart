import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import 'logic/login_logic.dart';
import 'widgets/login_header.dart';
import 'widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.headerGradientStart,
              AppColors.headerGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: ChangeNotifierProvider(
            create: (_) => LoginLogic(),
            child: const Column(
              children: [
                LoginHeader(),
                LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
