import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_colors.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'reviews'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'see_all'.tr(),
                style: TextStyle(
                  color: const Color(0xFF9E86E1),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildReviewItem(
          name: 'Raka P.',
          initial: 'R',
          avatarColor: const Color(0xFFF1E6FA), // Light purple
          rating: 5,
          text: 'Genuinely changed how I plan my mornings. Short chapters, easy to pick up between classes.',
        ),
        Divider(color: AppColors.border, height: 32.h),
        _buildReviewItem(
          name: 'Sindy A.',
          initial: 'S',
          avatarColor: const Color(0xFFE0F4FA), // Light blue
          rating: 4,
          text: 'Practical frameworks, though a little repetitive by the last few chapters.',
        ),
      ],
    );
  }

  Widget _buildReviewItem({
    required String name,
    required String initial,
    required Color avatarColor,
    required int rating,
    required String text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16.w,
              backgroundColor: avatarColor,
              child: Text(
                initial,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star,
                      color: index < rating ? Colors.amber : Colors.grey.shade300,
                      size: 12.w,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          text,
          style: TextStyle(
            color: AppColors.textSecondary,
            height: 1.5,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}
