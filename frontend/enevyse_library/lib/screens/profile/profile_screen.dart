import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../theme/app_colors.dart';
import 'widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isAdmin = user?.role == 'admin';

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'settings'.tr(),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Info Card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: user.profilePictureUrl.isNotEmpty
                        ? NetworkImage(user.profilePictureUrl)
                        : null,
                    child: user.profilePictureUrl.isEmpty
                        ? Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        GestureDetector(
                          onTap: () {
                            context.push('/update-profile');
                          },
                          child: Row(
                            children: [
                              Icon(Icons.edit,
                                  size: 14.w, color: AppColors.primary),
                              SizedBox(width: 4.w),
                              Text(
                                'update_profile'.tr(),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Admin Panel
            if (isAdmin) ...[
              _buildSectionHeader(context, 'admin_panel'.tr()),
              ProfileMenuItem(
                icon: Icons.add_box_outlined,
                title: 'add_book'.tr(),
                onTap: () => context.push('/admin/add-book'),
              ),
              SizedBox(height: 8.h),
              ProfileMenuItem(
                icon: Icons.edit_document,
                title: 'manage_books'.tr(),
                onTap: () => context.push('/admin/edit-book'),
              ),
              SizedBox(height: 8.h),
              ProfileMenuItem(
                icon: Icons.check_circle_outline,
                title: 'approve_book'.tr(),
                onTap: () {
                  context.push('/admin/approve-book');
                },
              ),
              SizedBox(height: 32.h),
            ],

            // Target
            _buildSectionHeader(context, 'target'.tr()),
            ProfileMenuItem(
              icon: Icons.favorite_border,
              title: 'favorites'.tr(),
              onTap: () {
                context.push('/profile/favorites');
              },
            ),
            SizedBox(height: 32.h),

            // General
            _buildSectionHeader(context, 'general'.tr()),
            ProfileMenuItem(
              icon: Icons.language,
              title: 'language_setting'.tr(),
              trailingText: context.locale.languageCode == 'id'
                  ? 'Bahasa Indonesia'
                  : 'English',
              onTap: () {
                if (context.locale.languageCode == 'en') {
                  context.setLocale(const Locale('id'));
                } else {
                  context.setLocale(const Locale('en'));
                }
              },
            ),

            SizedBox(height: 32.h),

            // Support
            _buildSectionHeader(context, 'support'.tr()),
            ProfileMenuItem(
              icon: Icons.logout,
              title: 'logout'.tr(),
              isDestructive: true,
              onTap: () async {
                final authProv = context.read<AuthProvider>();
                await authProv.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
