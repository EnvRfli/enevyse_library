import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/mock_book.dart';
import '../../../theme/app_colors.dart';

class BookCard extends StatelessWidget {
  final MockBook book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.w, // Fixed width for horizontal scrolling
      margin: EdgeInsets.only(right: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover Placeholder
          Container(
            height: 190.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: book.placeholderColor,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: book.placeholderColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Text(
                  book.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Title
          Text(
            book.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),

          // Author
          Text(
            book.author,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),

          // Rating and Availability
          Row(
            children: [
              // Stars
              Icon(Icons.star, color: Colors.amber, size: 14.w),
              Icon(Icons.star, color: Colors.amber, size: 14.w),
              Icon(Icons.star, color: Colors.amber, size: 14.w),
              Icon(Icons.star, color: Colors.amber, size: 14.w),
              Icon(Icons.star_half, color: Colors.amber, size: 14.w),
              SizedBox(width: 4.w),
              Text(
                book.rating.toString(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: book.availableCount > 0
                  ? const Color(0xFFE8F6EF) // Light green
                  : const Color(0xFFFFF0E6), // Light orange
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              book.availableCount > 2
                  ? 'available'.tr()
                  : (book.availableCount > 0 ? '${book.availableCount} ${'left'.tr()}' : 'unavailable'.tr()),
              style: TextStyle(
                color: book.availableCount > 0
                    ? const Color(0xFF32B37A) // Green text
                    : const Color(0xFFF28C50), // Orange text
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
