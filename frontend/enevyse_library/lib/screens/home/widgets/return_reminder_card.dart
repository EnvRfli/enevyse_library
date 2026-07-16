import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../models/transaction.dart';

class ReturnReminderCard extends StatelessWidget {
  final Transaction transaction;

  const ReturnReminderCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final daysLeft = transaction.dueDate.difference(DateTime.now()).inDays;

    String daysLeftStr;
    String dueDesc;
    if (daysLeft > 0) {
      daysLeftStr = '$daysLeft ${'days_left'.tr()}';
      dueDesc = 'return_due_desc'.tr(args: [daysLeft.toString()]);
    } else if (daysLeft == 0) {
      daysLeftStr = 'today'.tr();
      dueDesc = 'return_due_desc_today'.tr();
    } else {
      daysLeftStr = 'overdue'.tr();
      dueDesc = 'return_due_desc_overdue'.tr(args: [(-daysLeft).toString()]);
    }

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
            // Book Details
            Text(
              transaction.book?.title ?? 'Unknown Book',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 4.h),
            Text(
              dueDesc,
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
                        daysLeftStr,
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
                  onPressed: () {
                    context.push('/borrow-detail/${transaction.id}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF262942), // Dark Navy
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
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
