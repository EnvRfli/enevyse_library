import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../models/book.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/star_rating_widget.dart';
import '../../book_detail/function/build_fallback_cover.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final bool isGrid;

  const BookCard({super.key, required this.book, this.isGrid = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/book/${book.id}');
      },
      child: Container(
      width: isGrid ? null : 140.w, // Fixed width for horizontal scrolling
      margin: isGrid ? EdgeInsets.zero : EdgeInsets.only(right: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover Placeholder
            Container(
              height: 190.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                    ? Image.network(
                        book.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => buildFallbackCover(book.title),
                      )
                    : buildFallbackCover(book.title),
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
              StarRatingWidget(rating: book.ratings, size: 14.0),
              SizedBox(width: 4.w),
              Text(
                book.ratings.toStringAsFixed(1),
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
              color: book.availableCopies > 0
                  ? const Color(0xFF32B37A).withValues(alpha: 0.1) // Green
                  : const Color(0xFFF28C50).withValues(alpha: 0.1), // Orange
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              book.availableCopies > 0 ? 'available'.tr() : 'borrowed'.tr(),
              style: TextStyle(
                color: book.availableCopies > 0
                    ? const Color(0xFF32B37A)
                    : const Color(0xFFF28C50),
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
