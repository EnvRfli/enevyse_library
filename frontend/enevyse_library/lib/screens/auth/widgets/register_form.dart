import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_colors.dart';
import '../logic/register_logic.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Provider.of<RegisterLogic>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 40.h,
            bottom: 24.h,
          ),
          child: Form(
            key: logic.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  hintText: 'name'.tr(),
                  controller: logic.nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'name_required'.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  hintText: 'email'.tr(),
                  controller: logic.emailController,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'email_required'.tr();
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'invalid_email'.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  hintText: 'password'.tr(),
                  controller: logic.passwordController,
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'password_required'.tr();
                    }
                    if (value.length < 8) {
                      return 'password_too_short'.tr();
                    }
                    if (!RegExp(r'^(?=.*[A-Z])(?=.*\d).*$').hasMatch(value)) {
                      return 'password_complexity'.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32.h),
                ElevatedButton(
                  onPressed: (!logic.isFormValid || authProvider.isLoading)
                      ? null
                      : () => logic.handleRegister(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: authProvider.isLoading
                      ? SizedBox(
                          width: 24.h,
                          height: 24.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('register'.tr()),
                ),
                SizedBox(height: 48.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'already_have_account'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: Text(
                        'login'.tr(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
