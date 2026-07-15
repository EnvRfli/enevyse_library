import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.currentUser?.name ?? 'User';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

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
                'good_morning'.tr(),
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
                child: IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  color: AppColors.textPrimary,
                  iconSize: 20.w,
                  onPressed: () {},
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 40.w,
                height: 40.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B9CEB), Color(0xFF63B8D9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
