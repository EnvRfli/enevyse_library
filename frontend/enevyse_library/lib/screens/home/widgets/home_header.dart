import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  String getGreetingKey() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'good_morning';
    } else if (hour < 15) {
      return 'good_afternoon';
    } else if (hour < 18) {
      return 'good_evening';
    } else {
      return 'good_night';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final userName = user?.name ?? 'User';
    final profilePictureUrl = user?.profilePictureUrl ?? '';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Greeting Texts
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getGreetingKey().tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(width: 8.w),
                  const Text('✨'), // Emoji for the spark
                ],
              ),
            ],
          ),

          // Action Buttons (Notification & Avatar)
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
              ),
              SizedBox(width: 12.w),
              CircleAvatar(
                radius: 20.w,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: profilePictureUrl.isNotEmpty
                    ? NetworkImage(profilePictureUrl)
                    : null,
                child: profilePictureUrl.isEmpty
                    ? Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
