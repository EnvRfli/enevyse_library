import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_colors.dart';

class ReturnReminderCard extends StatelessWidget {
  const ReturnReminderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFDF0E5), // Mocca/Terracotta soft accent
          borderRadius: BorderRadius.circular(24.r),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.library_books,
                  color: const Color(0xFFD67D55),
                  size: 16.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  'return_reminder_title'.tr(),
                  style: TextStyle(
                    color: const Color(0xFFD67D55),
                    fontWeight: FontWeight.w800,
                    fontSize: 12.sp,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Book Details
            Text(
              'Atomic Habits',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 4.h),
            Text(
              'return_due_desc'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            SizedBox(height: 20.h),

            // Bottom Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Timer Pill
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: const Color(0xFFD67D55).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_alarm_rounded,
                        color: const Color(0xFFD67D55),
                        size: 14.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'days_left'.tr(),
                        style: TextStyle(
                          color: const Color(0xFFD67D55),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // View Details Button
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF262942), // Dark Navy
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: Text(
                    'view_details'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

