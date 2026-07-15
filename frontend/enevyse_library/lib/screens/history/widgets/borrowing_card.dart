import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../models/transaction.dart';
import '../../../theme/app_colors.dart';

class BorrowingCard extends StatelessWidget {
  final Transaction transaction;
  final bool isHistory;

  const BorrowingCard({super.key, required this.transaction, this.isHistory = false});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');
    final borrowStr = dateFormat.format(transaction.borrowDate);
    final dueStr = dateFormat.format(transaction.dueDate);

    // Calculate progress (from 0.0 to 1.0)
    final totalDuration = transaction.dueDate.difference(transaction.borrowDate).inDays;
    final passedDuration = DateTime.now().difference(transaction.borrowDate).inDays;
    
    double progress = totalDuration > 0 ? passedDuration / totalDuration : 1.0;
    if (progress < 0) progress = 0.0;
    if (progress > 1) progress = 1.0;

    final daysLeft = transaction.daysLeft;
    final isUrgent = daysLeft <= 3;
    final badgeColor = isHistory
        ? const Color(0xFFF2F2F5) // Grey
        : isUrgent
            ? const Color(0xFFFDF0E5) // Soft orange
            : const Color(0xFFE8F9EE); // Soft green
            
    final badgeTextColor = isHistory
        ? AppColors.textSecondary
        : isUrgent
            ? const Color(0xFFD67D55) // Orange text
            : const Color(0xFF32B37A); // Green text

    String badgeText = '';
    if (isHistory) {
      badgeText = 'returned'.tr();
    } else {
      badgeText = daysLeft < 0 
          ? '${daysLeft.abs()} ${'days_overdue'.tr()}'
          : '$daysLeft ${'days_left'.tr()}';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover
              Container(
                width: 60.w,
                height: 85.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12.r),
                  image: transaction.book?.coverUrl != null && transaction.book!.coverUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(transaction.book!.coverUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              SizedBox(width: 16.w),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.book?.title ?? 'Unknown Book',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${'borrowed'.tr()} $borrowStr · ${'due'.tr()} $dueStr',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Progress Bar
          if (!isHistory)
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6.h,
                    backgroundColor: const Color(0xFFF2F2F5),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isUrgent ? const Color(0xFFD67D55) : const Color(0xFF8B9CEB),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
            
          // View Detail Button
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: OutlinedButton(
              onPressed: () {
                context.push('/borrow-detail/${transaction.id}');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              ),
              child: Text(
                'view_detail'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
